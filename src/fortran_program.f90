module fortran_program
  use file_system

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

  function construct_program(target_file, name) result(new_program)
    type(Program) :: new_program
    character(len=*), intent(in) :: target_file, name

    new_program%target_file = target_file
    new_program%name = name
  end function

  function generate(this) result(return_value)
    class(Program) :: this
    logical :: return_value
    type(File) :: main

    return_value = .false.
    main = File(this%target_file)
    if (.not. main%write_line('program generate')) return
    if (.not. main%write_line('end program')) return

    return_value = .true.

  end function

end module
