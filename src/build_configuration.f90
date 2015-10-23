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
     procedure, private :: build_edges
     procedure, private :: compilation_edges_for_components
     procedure, private :: component_libraries
     procedure, private :: dependencies_of_executable
     procedure, private :: link_edges_for_components
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
    type(File) :: output

    return_value = .false.
    output = File(this%path)
    if (.not. variable_declarations(output)) return
    if (.not. rules(output)) return
    return_value = this%build_edges(output)
  end function

  function variable_declarations(output) result(return_value)
    type(File), intent(in) :: output
    logical :: return_value
    return_value = .false.
    if (.not. output%write_line('ninja_required_version = 1.6.0')) return
    if (.not. output%write_line('builddir = build')) return
    if (.not. output%write_line('configuration = debug')) return
    if (.not. output%write_line('output_directory = $builddir/$configuration')) return
    if (.not. output%write_line('fflags = ' // compilation_options())) return
    if (.not. output%write_line('ldflags = ' // linking_options())) return
    return_value = output%write_line('')
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

  function rules(output) result(return_value)
    type(File), intent(in) :: output
    logical :: return_value

    return_value = .false.
    if (.not. compilation_rule(output)) return
    if (.not. static_library_rule(output)) return
    return_value = linking_rule(output)
  end function

  function compilation_rule(output) result(return_value)
    type(File), intent(in) :: output
    logical :: return_value
    return_value = .false.
    if (.not. output%write_line('rule fc')) return
    if (.not. output%write_line('  command = ifort $fflags $in /object:$out')) return
    return_value = output%write_line('')
  end function

  function static_library_rule(output) result(return_value)
    type(File), intent(in) :: output
    logical :: return_value
    return_value = .false.
    if (.not. output%write_line('rule flib')) return
    if (.not. output%write_line('  command = lib /OUT:$out /NOLOGO $in')) return
    return_value = output%write_line('')
  end function

  function linking_rule(output) result(return_value)
    type(File), intent(in) :: output
    logical :: return_value

    return_value = .false.
    if (.not. output%write_line('rule flink')) return
    if (.not. output%write_line('  command = link /OUT:$out $ldflags $in')) return
    return_value = output%write_line('')
  end function

  function build_edges(this, output) result (return_value)
    class(BuildConfiguration) :: this
    type(File), intent(in) :: output
    logical :: return_value

    return_value = .false.
    if (.not. output%write_line( &
         compilation_edge('main.f90', &
         implicit=this%component_main_objects()))) return
    if (.not. this%compilation_edges_for_components(output)) return
    if (.not. this%link_edges_for_components(output)) return
    return_value = output%write_line( &
         linking_edge('$output_directory/generated.exe', &
         this%dependencies_of_executable()))
  end function

  function component_main_objects(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = to_object_path(this%components(1)%main_file)
  end function

  function compilation_edges_for_components(this, output) result (return_value)
    class(BuildConfiguration) :: this
    type(File), intent(in) :: output
    logical :: return_value
    return_value = compilation_edges_for_component(output, this%components(1))
  end function

  function compilation_edges_for_component(output, component_data) &
       result (return_value)
    type(File), intent(in) :: output
    type(ComponentData) :: component_data
    logical :: return_value
    character(len=:), allocatable :: file_name
    integer :: i

    return_value = .false.
    file_name = extract_file_name_from_path(component_data%main_file)
    if (.not. output%write_line( &
         compilation_edge(file_name, &
         implicit=objects_of_component(component_data)))) return

    do i=1, component_data%files()
       file_name = extract_file_name_from_path(component_data%file_at(i))
       if (.not. output%write_line(compilation_edge(file_name))) return
    end do

    return_value = .true.
  end function

  function link_edges_for_components(this, output) result (return_value)
    class(BuildConfiguration) :: this
    type(File), intent(in) :: output
    logical :: return_value
    return_value = link_edges_for_component(output, this%components(1))
  end function

  function link_edges_for_component(output, component_data) &
       result (return_value)
    type(File), intent(in) :: output
    type(ComponentData), intent(in) :: component_data
    logical :: return_value

    return_value = output%write_line( &
         static_link_edge(component_data%name, &
         all_objects_of_component(component_data)))
  end function

  function dependencies_of_executable(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = '$output_directory/main.obj ' // this%component_libraries()
  end function

  function component_libraries(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = component_library(this%components(1))
  end function

  function component_library(component_data) result (return_value)
    class(ComponentData) :: component_data
    character(len=:), allocatable :: return_value
    return_value = component_library_path(component_data%name)
  end function

  function objects_of_components(this) result (return_value)
    class(BuildConfiguration) :: this
    character(len=:), allocatable :: return_value
    return_value = all_objects_of_component(this%components(1))
  end function

  function all_objects_of_component(component_data) result (return_value)
    class(ComponentData) :: component_data
    character(len=:), allocatable :: return_value
    return_value = to_object_path(component_data%main_file) // &
         objects_of_component(component_data)
  end function

  function objects_of_component(component_data) result (return_value)
    class(ComponentData) :: component_data
    character(len=:), allocatable :: return_value
    integer :: i
    return_value = ''
    do i=1, component_data%files()
       ! Probably not a stellar idea to allocate the return value from
       ! start all over again in each loop (assuming Fortran is not
       ! smart enough to optimize this).
       ! But it is simple and gets the job done (well enough)
       return_value = return_value // ' ' // &
            to_object_path(component_data%file_at(i))
    end do
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

  function static_link_edge(module_name, objects) result (return_value)
    character(len=*), intent(in)  :: module_name
    character(len=*), intent(in)  :: objects
    character(len=:), allocatable :: return_value
    return_value = build_edge( &
         component_library_path(module_name), 'flib', objects)
  end function

  function component_library_path(module_name) result (return_value)
    character(len=*), intent(in)  :: module_name
    character(len=:), allocatable :: return_value
    return_value = in_output_directory(module_name // '.lib')
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
    return_value = in_output_directory(object_file)
  end function

  function in_output_directory(file) result (return_value)
    character(len=*), intent(in) :: file
    character(len=:), allocatable :: return_value
    return_value = '$output_directory/' // file
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
