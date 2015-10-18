module program_structure
  use configuration

  implicit none

  private

  type, public :: ComponentData
     character(len=:), allocatable :: name
     character(len=:), allocatable :: main_file
     character(len=:), allocatable :: files(:)
  end type

  public :: analyze_needed_components
  private :: new_component

contains

  ! There were few surprises in the implementation of this procedure.
  ! These may be compiler bugs or just reflection of my poor
  ! understanding of Fortran.
  !
  ! 1) I originally implemented this as function, but the return_value
  ! did not point to valid memory after return. So, I changed the
  ! result to be passed as an out parameter instead
  !
  ! 2) I had assumed that array constructors would be able to deduce
  ! the size of the new array automatically. However, that does not
  ! seem to be the case. Instead, I had to explicitly allocate the
  ! result array and give the required size.
  subroutine analyze_needed_components(the_options, return_value)
    type(Options), intent(in) :: the_options
    type(ComponentData), allocatable, intent(out) :: return_value(:)
    allocate(return_value(1))
    ! Note: the main file of a component is included in the file count
    !       -> always reduce the file count by 1
    return_value = [new_component(the_options%target_directory, 0, &
         the_options%file_count-1)]
  end subroutine

  function new_component(target_directory, counter, file_count) &
       result(return_value)
    type(ComponentData) :: return_value
    character(len=*), intent(in) :: target_directory
    integer, intent(in) :: counter, file_count
    character(len=:), allocatable :: id

    id = component_id(counter)

    ! Passing empty string as a "file", because compiler crashes otherwise
    ! Besides there will later be values
    return_value = ComponentData(id, &
         component_main_file(target_directory, id), &
         files_for_a_component(target_directory, id, file_count))
  end function

  function component_main_file(target_directory, id) result(return_value)
    character(len=:), allocatable :: return_value
    character(len=*), intent(in) :: target_directory
    character(len=*), intent(in) :: id
    return_value = target_directory // '/' // id // '_main.f90'
  end function

  function files_for_a_component(target_directory, id, file_count) &
       result(return_value)
    character(len=:), allocatable :: return_value(:)
    character(len=*), intent(in) :: target_directory
    character(len=*), intent(in) :: id
    integer, intent(in) :: file_count
    integer :: i
    character(len=2056) :: path

    allocate(character(len=2056) :: return_value(file_count))
    do i=1, file_count
       write(path, "(A, I0, A)") target_directory // '/' // id // '_', i, '.f90'
       return_value(i) = trim(path)
    end do
  end function

  function component_id(counter) result(return_value)
    character(len=:), allocatable :: return_value
    integer, intent(in) :: counter
    return_value = trim(char(ichar('A') + counter))
  end function
end module
