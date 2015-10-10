module build_configuration

  use file_system

  implicit none

  private

  type, public :: BuildConfiguration
     character(len=:), allocatable :: path
   contains
     procedure :: generate
  end type

  interface BuildConfiguration
     module procedure :: construct_configuration
  end interface

contains

  function construct_configuration(directory) result(new_configuration)
    type(BuildConfiguration) :: new_configuration
    character(len=*) :: directory
    new_configuration%path = directory // '/build.ninja'
  end function

  function generate(this) result(return_value)
    class(BuildConfiguration) :: this
    logical :: return_value
    character(len=:), allocatable :: declarations(:), rule_lines(:), lines(:)

    declarations = variable_declarations()
    rule_lines = rules()
    lines = [declarations, rule_lines]
    return_value = write_to_file(this%path, lines)
  end function

  function write_to_file(path, lines) result(return_value)
    character(len=*) :: path
    character(len=:), allocatable :: lines(:)
    logical :: return_value

    type(File) :: ninja
    integer :: i

    ninja = File(path)
    return_value = .false.

    do i = 1, size(lines)
       if (.not. ninja%write_line(trim(lines(i)))) return
    end do

    return_value = .true.
  end function

  function variable_declarations() result(return_value)
    character(len=:), allocatable :: return_value(:)

    ! This declares all lines to be of the same length. This is a hack
    ! that is necessary because of my lack of understanding of Fortran
    ! and/or limitations of Fortran language. It would have been nicer
    ! to let compiler allocate exactly the needed space, but I was not
    ! able to figure out how to do that. An unfortunate result from
    ! this is that the lines need to be trimmed before they are
    ! written to the file.
    return_value = (/ character(1024) :: &
         'ninja_required_version = 1.6.0', &
         'builddir = build', &
         'configuration = debug', &
         'output_directory = $builddir/$configuration', &
         'fflags = ' // compilation_options(), &
         ''/)
  end function

  function compilation_options() result(return_value)
    character(:), allocatable :: return_value
    return_value = '/nologo ' // &
         '/debug:full ' // &
         '/Od ' // &
         '/I$output_directory ' // &
         '/stand:f08 ' // &
         '/warn:all ' // &
         '/module:$output_directory ' // &
         '/Fd$output_directory\vc140.pdb ' // &
         '/traceback ' // &
         '/check:bounds ' // &
         '/check:stack ' // &
         '/threads ' // &
         '/dbglibs ' // &
         '/c ' // &
         '/Qlocation,link,"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin"'
  end function compilation_options

  function rules() result(return_value)
    character(len=:), allocatable :: return_value(:)
    return_value = compilation_rule()
  end function

  function compilation_rule() result(return_value)
    character(len=:), allocatable :: return_value(:)
    return_value = [ character(1024) :: &
         'rule fc', &
         '  command = ifort $fflags $in /object:$out', &
         '']
  end function

end module
