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
    if (.not. this%generate_subroutine(component_file)) return
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
    type(File) :: component_file

    component_file = File(path)
    return_value = .false.
    if (.not. component_file%write_line('')) return
    return_value = .true.
  end function

  function generate_subroutine(this, output) result(return_value)
    class(Component) :: this
    type(File), intent(in) :: output
    character(len=:), allocatable :: declaration
    logical :: return_value

    return_value = .false.
    declaration = 'subroutine call_' // this%component_data%name // '()'
    if (.not. output%write_line(declaration)) return
    if (.not. output%write_line('write (*, "(A)") __FILE__')) return
    if (.not. output%write_line('end subroutine')) return
    return_value = .true.
  end function
end module
