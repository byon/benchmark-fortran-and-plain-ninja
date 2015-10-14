module program_component

  use configuration

  implicit none

  private

  type, public :: Component
     character(len=:), allocatable :: target_directory
     character(len=:), allocatable :: name
     integer :: file_count
   contains
     procedure :: generate
     procedure, private :: generate_file
  end type

  interface Component
     module procedure :: construct_component
  end interface

  public :: construct_component
contains

  function construct_component(the_options, name) result(new_component)
    type(Component) :: new_component
    type(Options), intent(in) :: the_options
    character(len=*), intent(in) :: name

    new_component%target_directory = the_options%target_directory
    new_component%name = name
    new_component%file_count = the_options%file_count
  end function

  function generate(this) result(return_value)
    class(Component) :: this
    logical :: return_value
    character(len=:), allocatable :: path
    path = this%target_directory // '/' // this%name // '_1.f90'
    return_value = this%generate_file(path)
  end function

  function generate_file(this, path) result(return_value)
    use file_system

    class(Component) :: this
    character(len=*) :: path
    logical :: return_value
    type(File) :: component_file

    component_file = File(path)
    return_value = component_file%write_line('module ' // this%name)
    return_value = component_file%write_line('end module')
  end function
end module
