module build_configuration

  use file_system
  use program_structure

  implicit none

  private

  type, public :: BuildConfiguration
     character(len=:), allocatable :: path
    type(ComponentData), allocatable :: components(:)
   contains
     procedure :: generate
     procedure, private :: all_objects
     procedure, private :: build_edges
     procedure, private :: compilation_edges_for_components
     procedure, private :: component_main_objects
     procedure, private :: objects_of_components
  end type

  interface BuildConfiguration
     module procedure :: construct_configuration
  end interface

contains

  function construct_configuration(directory, components) result(new_configuration)
    type(BuildConfiguration) :: new_configuration
    character(len=*), intent(in) :: directory
    type(ComponentData), allocatable, intent(in) :: components(:)
    new_configuration%path = directory // '/build.ninja'
    allocate(new_configuration%components, source=components)
  end function

  function generate(this) result(return_value)
    class(BuildConfiguration) :: this
    logical :: return_value
    character(len=:), allocatable :: lines(:)

    lines = [variable_declarations(), rules(), this%build_edges()]
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
         'ldflags = ' // linking_options(), &
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
         '/fpp ' // &
         '/Qlocation,link,"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin"'
  end function compilation_options

  function linking_options() result(return_value)
    character(:), allocatable :: return_value
    return_value = '/INCREMENTAL:NO ' // &
         '/NOLOGO ' // &
         '/DEBUG ' // &
         '/PDB:$output_directory/debug_info.pdb ' // &
         '/SUBSYSTEM:CONSOLE ' // &
         '/MACHINE:X64'
  end function

  function rules() result(return_value)
    character(len=:), allocatable :: return_value(:)
    return_value = [compilation_rule(), linking_rule()]
  end function

  function compilation_rule() result(return_value)
    character(len=:), allocatable :: return_value(:)
    return_value = [ character(1024) :: &
         'rule fc', &
         '  command = ifort $fflags $in /object:$out', &
         '']
  end function

  function linking_rule() result(return_value)
    character(len=:), allocatable :: return_value(:)
    return_value = [ character(1024) :: &
         'rule flink', &
         '  command = link /OUT:$out $ldflags $in', &
         '']
  end function

  function build_edges(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value(:)
    return_value = [compilation_edge('main.f90', implicit=this%component_main_objects()), &
         this%compilation_edges_for_components(), &
         linking_edge('$output_directory/generated.exe', this%all_objects())]
  end function

  function component_main_objects(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = to_object_path(this%components(1)%main_file)
  end function

  function compilation_edges_for_components(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = compilation_edge(extract_file_name_from_path(this%components(1)%main_file))
  end function

  function all_objects(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = '$output_directory/main.obj ' // this%objects_of_components()
  end function

  function objects_of_components(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = objects_of_component(this%components(1))
  end function

  function objects_of_component(component_data) result (return_value)
    class(ComponentData) :: component_data
    character(len=:), allocatable :: return_value
    return_value = to_object_path(component_data%main_file)
  end function

  function compilation_edge(file, explicit, implicit) result (return_value)
    character(len=*), intent(in)  :: file
    ! @todo it might be better to pass dependencies as array?
    character(len=*), intent(in), optional  :: explicit
    character(len=*), intent(in), optional  :: implicit
    character(len=:), allocatable :: return_value
    character(len=:), allocatable :: compilation
    compilation = file
    if (present(explicit)) compilation = compilation  // ' ' // explicit
    return_value = build_edge(to_object_path(file), 'fc', &
         compilation, implicit)
  end function

  function linking_edge(file, dependencies) result (return_value)
    character(len=*), intent(in)  :: file
    character(len=*), intent(in)  :: dependencies
    character(len=:), allocatable :: return_value
    return_value = build_edge(file, 'flink', dependencies)
  end function

  function build_edge(outputs, rule, explicit, implicit) &
       result (return_value)
    character(len=*), intent(in)  :: outputs
    character(len=*), intent(in)  :: rule
    character(len=*), intent(in)  :: explicit
    character(len=*), intent(in), optional  :: implicit
    character(len=:), allocatable :: return_value
    return_value = 'build ' // outputs // ' : ' // rule // ' ' // explicit
    if (present(implicit)) then
       return_value = return_value // ' | ' // implicit
    end if
  end function

  function to_object_path(file) result (return_value)
    character(len=*), intent(in) :: file
    character(len=:), allocatable :: return_value
    character(len=:), allocatable :: object_file
    object_file = replace_file_extension(extract_file_name_from_path(file))
    return_value = '$output_directory/' // object_file
  end function

  function replace_file_extension(file) result (return_value)
    character(len=*), intent(in) :: file
    character(len=:), allocatable :: return_value
    integer :: dot_index

    dot_index = index(file, '.', back=.true.)
    ! @todo improve error handling
    if (dot_index == 0) stop 1
    return_value = file(1:dot_index) // 'obj'
  end function

  function extract_file_name_from_path(path) result (return_value)
    character(len=*), intent(in) :: path
    character(len=:), allocatable :: return_value
    integer :: last_separator

    last_separator = index(path, '/', back=.true.)
    if (last_separator == 0) then
       return_value = path
       return
    end if
    return_value = path(last_separator + 1:)
  end function
end module
