program generate

  use build_configuration
  use file_system
  use fortran_program

  implicit none

  type(BuildConfiguration) configuration_file
  type(Program) :: main

  if (.not. create_directory('generated')) stop 1

  main = Program('generated/main.f90', 'generate')

  if (.not. configuration_file%generate()) stop 1
  if (.not. main%generate()) stop 1

contains

end program generate
