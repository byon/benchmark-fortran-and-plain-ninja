program generate

  use build_configuration
  use configuration
  use file_system
  use fortran_program
  use program_structure

  implicit none

  type(BuildConfiguration) :: configuration_file
  type(ComponentData), allocatable :: components(:)
  type(Options) :: the_options
  type(Program) :: main

  the_options = construct_options('generated', 'generate')
  if (.not. the_options%validate()) stop 1

  call analyze_needed_components(the_options, components)

  if (.not. create_directory(the_options%target_directory)) stop 1

  configuration_file = BuildConfiguration(the_options%target_directory,  &
       components)
  if (.not. configuration_file%generate()) stop 1

  main = construct_program(the_options%target_directory, &
       the_options%program_name, components)
  if (.not. main%generate()) stop 1

end program generate
