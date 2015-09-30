module file_system

  implicit none

  private

  type, public :: File
     integer :: out_unit
     integer :: success
   contains
     final :: destruct_file
  end type File

  interface File
     module procedure :: construct_file
  end interface

  public :: create_directory, error, construct_file

contains

  function construct_file(path) result(new_file)
    type(File) :: new_file
    character(len=*) :: path

    open(newunit=new_file%out_unit, file=path, iostat=new_file%success, &
         action='write', status='replace')
    if ( .not. new_file%success /= 0) then
       call error('Failed to create "' // path // '"')
    end if
  end function

  subroutine destruct_file(this)
    type(File) :: this
    if (this%success /= 0) close(this%out_unit)
  end subroutine

  function create_directory(directory) result(return_value)
    use ifport
    character(len=*) :: directory
    logical :: return_value
    return_value = makedirqq(directory)
    if (.not. return_value) then
       call error('Failed to create output directory "' // directory // '"')
    end if
  end function

  ! This function belongs somewhere else
  subroutine error(message)
    use iso_fortran_env, only : error_unit
    character(len=*) message
    write(error_unit, '(a)') message
  end subroutine error
end module
