module file_system

  implicit none

  private

  type, public :: File
     integer :: out_unit
     integer :: success
   contains
     final :: destruct_file
     procedure :: write_line
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
    if (new_file%success /= 0) then
       call error('Failed to create "' // path // '"')
    end if
  end function

  subroutine destruct_file(this)
    type(File) :: this
    if (this%success /= 0) close(this%out_unit)
  end subroutine

  function write_line(this, to_write) result(return_value)
    class(File) :: this
    character(len=*), intent(in) :: to_write
    logical :: return_value
    integer :: write_success

    if (this%success /= 0) then
       call error('Cannot write to file that is not opened')
       return_value = .false.
       return
    end if

    write(this%out_unit, '(A)', iostat=write_success) to_write
    return_value = write_success == 0
    if (.not. return_value) call error('Writing to file failed')
  end function

  function create_directory(directory) result(return_value)
    use ifport
    character(len=*), intent(in) :: directory
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
