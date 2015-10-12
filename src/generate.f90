program generate

  use build_configuration
  use configuration
  use file_system
  use fortran_program

  implicit none

  type(BuildConfiguration) :: configuration_file
  type(Options) :: configuration_options
  type(Program) :: main
  character(len=*), parameter :: DIRECTORY = 'generated'

  configuration_options = Options()
  if (.not. configuration_options%validate()) stop 1

  if (.not. create_directory(DIRECTORY)) stop 1

  configuration_file = BuildConfiguration(DIRECTORY)
  if (.not. configuration_file%generate()) stop 1

  main = Program(DIRECTORY // '/main.f90', 'generate')
  if (.not. main%generate()) stop 1

end program generate
