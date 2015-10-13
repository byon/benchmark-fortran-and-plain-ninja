module configuration

  implicit none

  private

  type, public :: Options
     character(len=:), allocatable :: target_directory
     character(len=:), allocatable :: program_name
     integer :: file_count
   contains
     procedure :: validate
  end type

  interface Options
     module procedure :: construct_options
  end interface Options

  public :: construct_options

contains

  function construct_options(target_directory, program_name) &
       result(new_configuration)
    type(Options) :: new_configuration
    character(len=*) :: target_directory
    character(len=*) :: program_name
    new_configuration%file_count = get_integer_argument_at(1)
    new_configuration%target_directory = target_directory
    new_configuration%program_name = program_name
  end function

  function get_integer_argument_at(index) result(return_value)
    integer, intent(in) :: index
    integer :: return_value
    character(len=:), allocatable :: value
    value = get_string_argument_at(index)
    if (value == '') then
       return_value = -1
    else
       return_value = string_to_integer(value)
    end if
  end function

  function string_to_integer(string) result(return_value)
    character(len=*),intent(in) :: string
    integer :: return_value, status

    read(string,*,iostat=status) return_value
    if (status /= 0) return_value = -1
  end function

  function get_string_argument_at(index) result(return_value)
    integer, intent(in) :: index
    character(len=:), allocatable :: return_value
    character(len=1024) :: buffer
    integer :: status
    call get_command_argument(index, buffer, status=status)
    if (status == 0) then
       return_value = trim(buffer)
    else
       return_value = ''
    end if
  end function

  function validate(this) result(return_value)
    class(Options) :: this
    logical :: return_value

    if (this%file_count < 0) then
       call error('Error: missing file count')
       return_value = .false.
       return
    end if

    return_value = .true.
  end function validate

  ! @todo This function is duplicated
  subroutine error(message)
    use iso_fortran_env, only : error_unit
    character(len=*) message
    write(error_unit, '(a)') message
  end subroutine error

end module
