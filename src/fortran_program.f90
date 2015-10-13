module fortran_program
  use file_system
  use configuration

  implicit none

  private

  type, public :: Program
     character(len=:), allocatable :: target_file
     character(len=:), allocatable :: name
   contains
     procedure :: generate
  end type

  interface Program
     module procedure :: construct_program
  end interface

contains

  function construct_program(the_options) result(new_program)
    type(Program) :: new_program
    type(Options), intent(in) :: the_options

    new_program%target_file = the_options%target_directory // '/main.f90'
    new_program%name = the_options%program_name
  end function

  function generate(this) result(return_value)
    class(Program) :: this
    logical :: return_value
    type(File) :: main

    return_value = .false.
    main = File(this%target_file)
    if (.not. main%write_line('program ' // this%name)) return
    if (.not. main%write_line('write (*, "(A)") __FILE__')) return
    if (.not. main%write_line('end program')) return

    return_value = .true.

  end function

end module
