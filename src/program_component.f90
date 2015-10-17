module program_component

  use configuration
  use file_system

  implicit none

  private

  type, public :: Component
     character(len=:), allocatable :: target_directory
     character(len=:), allocatable :: name
     integer :: file_count
   contains
     procedure :: generate
     procedure, private :: generate_file
     procedure, private :: generate_subroutine
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
    class(Component) :: this
    character(len=*) :: path
    logical :: return_value
    type(File) :: component_file

    component_file = File(path)
    return_value = .false.
    if (.not. component_file%write_line('module ' // this%name)) return
    if (.not. component_file%write_line('contains')) return
    if (.not. this%generate_subroutine(component_file)) return
    if (.not. component_file%write_line('end module')) return
    return_value = .true.
  end function

  function generate_subroutine(this, output) result(return_value)
    class(Component) :: this
    type(File), intent(in) :: output
    character(len=:), allocatable :: declaration
    logical :: return_value

    return_value = .false.
    declaration = 'subroutine call_' // this%name // '()'
    if (.not. output%write_line(declaration)) return
    if (.not. output%write_line('end subroutine')) return
    return_value = .true.
  end function
end module
