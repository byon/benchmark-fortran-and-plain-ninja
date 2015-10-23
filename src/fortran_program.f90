module fortran_program
  use file_system
  use program_structure

  implicit none

  private

  type, public :: Program
     type(ComponentData), allocatable :: components(:)
     character(len=:), allocatable :: target_file
     character(len=:), allocatable :: program_name
     integer :: row_count
   contains
     procedure :: generate
     procedure, private :: generate_main
     procedure, private :: generate_use_statements
     procedure, private :: generate_component_calls
     procedure, private :: generate_components
  end type

  public :: construct_program

contains

  function construct_program(target_directory, program_name, components, &
       row_count) result(new_program)
    type(Program) :: new_program
    type(ComponentData), intent(in) :: components(:)
    character(len=*), intent(in) :: target_directory
    character(len=*), intent(in) :: program_name
    integer, intent(in) :: row_count

    new_program%target_file = target_directory // '/main.f90'
    new_program%program_name = program_name
    new_program%row_count = row_count
    ! Compiler allows simple assignment from parameter to member variable.
    ! However, that does not actually do anything, which will result in a
    ! crash later on.
    allocate(new_program%components, source=components)
  end function

  function generate(this) result(return_value)
    class(Program) :: this
    logical :: return_value

    return_value = this%generate_main() .and. this%generate_components()

  end function

  function generate_main(this) result(return_value)
    class(Program) :: this
    logical :: return_value
    type(File) :: main

    return_value = .false.
    main = File(this%target_file)
    if (.not. main%write_line('program ' // this%program_name)) return
    if (.not. this%generate_use_statements(main)) return
    if (.not. main%write_line('write (*, "(A)") __FILE__')) return
    if (.not. this%generate_component_calls(main)) return
    if (.not. main%write_line('end program')) return

    return_value = .true.
  end function

  function generate_use_statements(this, output) result(return_value)
    class(Program) :: this
    type(File), intent(in) :: output
    logical :: return_value
    integer :: i
    return_value = .false.

    do i = 1, size(this%components)
       if (.not. output%write_line('use ' // this%components(i)%name)) return
    end do
    return_value = .true.
  end function

  function generate_component_calls(this, output) result(return_value)
    class(Program) :: this
    type(File), intent(in) :: output
    logical :: return_value
    integer :: i
    character(:), allocatable :: call_line

    return_value = .false.

    do i = 1, size(this%components)
       call_line = 'call call_' // this%components(i)%name // '()'
       if (.not. output%write_line(call_line)) return
    end do

    return_value = .true.
  end function

  function generate_components(this) result(return_value)
    class(Program) :: this
    logical :: return_value
    integer :: i

    return_value = .false.
    do i = 1, size(this%components)
       if (.not. generate_component(this%components(i), this%row_count)) return
    end do

    return_value = .true.
  end function

  function generate_component(component_data, row_count) result(return_value)
    use program_component
    class(ComponentData), intent(in) :: component_data
    integer, intent(in) :: row_count
    logical :: return_value
    type(Component) :: a_component

    a_component = Component(component_data, row_count)
    return_value = a_component%generate()
  end function
end module
