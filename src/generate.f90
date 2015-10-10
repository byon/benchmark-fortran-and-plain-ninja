program generate

  use build_configuration
  use file_system

  implicit none

  type(File) :: main
  type(BuildConfiguration) configuration_file

  if (.not. create_directory('generated')) stop 1
  main = File('generated/main.f90')
  if (.not. main%write_line('program generate')) stop 1
  if (.not. main%write_line('end program')) stop 1

  if (.not. configuration_file%generate()) stop 1

contains

end program generate
