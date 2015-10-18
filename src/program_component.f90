module program_component

  use configuration
  use file_system
  use program_structure

  implicit none

  private

  type, public :: Component
     type(ComponentData) :: component_data
   contains
     procedure :: generate
     procedure, private :: generate_file
     procedure, private :: generate_files
     procedure, private :: generate_main_file
     procedure, private :: generate_main_subroutine
     procedure, private :: generate_subroutine
  end type

contains

  function generate(this) result(return_value)
    class(Component) :: this
    logical :: return_value
    return_value = .false.
    if (.not. this%generate_main_file(this%component_data%main_file)) return
    return_value = this%generate_files()
  end function

  function generate_main_file(this, path) result(return_value)
    class(Component) :: this
    character(len=*) :: path
    logical :: return_value
    type(File) :: component_file

    component_file = File(path)
    return_value = .false.
    if (.not. component_file%write_line('module ' // this%component_data%name)) return
    if (.not. component_file%write_line('contains')) return
    if (.not. this%generate_main_subroutine(component_file)) return
    if (.not. component_file%write_line('end module')) return
    return_value = .true.
  end function

  function generate_files(this) result(return_value)
    class(Component) :: this
    logical :: return_value
    integer :: i

    return_value = .false.
    do i = 1, size(this%component_data%files)
       if (.not. this%generate_file(this%component_data%files(i))) return
    end do
    return_value = .true.
  end function

  function generate_file(this, path) result(return_value)
    class(Component) :: this
    character(len=*) :: path
    logical :: return_value
    type(File) :: new_file
    character(len=:), allocatable :: name

    name = module_name_from_path(path)
    new_file = File(path)
    return_value = .false.
    if (.not. new_file%write_line('module ' // name)) return
    if (.not. new_file%write_line('contains')) return
    if (.not. this%generate_subroutine(new_file, 'call_' // name)) return
    if (.not. new_file%write_line('end module')) return
    return_value = .true.
  end function

  function generate_main_subroutine(this, output) result(return_value)
    class(Component) :: this
    type(File), intent(in) :: output
    character(len=:), allocatable :: name
    logical :: return_value

    name = 'call_' // this%component_data%name
    return_value = this%generate_subroutine(output, name)
  end function

  function generate_subroutine(this, output, name) result(return_value)
    class(Component) :: this
    type(File), intent(in) :: output
    character(len=*), intent(in) :: name
    character(len=:), allocatable :: declaration
    logical :: return_value

    return_value = .false.
    declaration = 'subroutine ' // name // '()'
    if (.not. output%write_line(declaration)) return
    if (.not. output%write_line('write (*, "(A)") __FILE__')) return
    if (.not. output%write_line('end subroutine')) return
    return_value = .true.
  end function

  function module_name_from_path(path) result(return_value)
    character(len=*) :: path
    character(len=:), allocatable :: return_value
    character(len=:), allocatable :: file_name
    file_name = extract_file_name_from_path(path)
    ! @todo: This would be a good place for asserting that separator was found
    return_value = file_name(:index(file_name, '.') - 1)
  end function

  ! @todo duplicated from build_configuration.f90
  function extract_file_name_from_path(path) result (return_value)
    character(len=*), intent(in) :: path
    character(len=:), allocatable :: return_value
    integer :: last_separator

    last_separator = index(path, '/', back=.true.)
    if (last_separator == 0) then
       return_value = path
       return
    end if
    return_value = path(last_separator + 1:)
  end function
end module
