program generate

  use build_configuration
  use configuration
  use file_system
  use fortran_program

  implicit none

  type(BuildConfiguration) :: configuration_file
  type(Options) :: the_options
  type(Program) :: main

  the_options = construct_options('generated', 'generate')
  if (.not. the_options%validate()) stop 1

  if (.not. create_directory(the_options%target_directory)) stop 1

  configuration_file = BuildConfiguration(the_options%target_directory)
  if (.not. configuration_file%generate()) stop 1

  main = Program(the_options)
  if (.not. main%generate()) stop 1

end program generate
