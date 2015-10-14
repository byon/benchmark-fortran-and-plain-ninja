module fortran_program
  use configuration
  use file_system

  implicit none

  private

  type, public :: Program
     type(Options) :: the_options
     character(len=:), allocatable :: target_file
   contains
     procedure :: generate
     procedure, private :: generate_main
     procedure, private :: generate_components
     procedure, private :: generate_component
     procedure, private :: component_path
  end type

  interface Program
     module procedure :: construct_program
  end interface

contains

  function construct_program(the_options) result(new_program)
    type(Program) :: new_program
    type(Options), intent(in) :: the_options

    new_program%target_file = the_options%target_directory // '/main.f90'
    new_program%the_options = the_options
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
    if (.not. main%write_line('program ' // this%the_options%program_name)) return
    if (.not. main%write_line('write (*, "(A)") __FILE__')) return
    if (.not. main%write_line('end program')) return

    return_value = .true.
  end function

  function generate_components(this) result(return_value)
    class(Program) :: this
    logical :: return_value
    integer :: i

    return_value = .false.
    do i = 0, this%the_options%file_count - 1
       if (.not. this%generate_component(i)) return
    end do

    return_value = .true.
  end function

  function generate_component(this, id) result(return_value)
    use program_component

    class(Program) :: this
    integer, intent(in) :: id
    logical :: return_value
    type(Component) :: a_component
    a_component = construct_component(this%the_options, this%component_path(id))
    return_value = a_component%generate()
  end function

  function component_path(this, id) result(return_value)
    class(Program) :: this
    character(len=:), allocatable :: return_value
    integer, intent(in) :: id
    return_value = trim(char(ichar('A') + id))
  end function
end module
