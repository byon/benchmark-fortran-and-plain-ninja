program generate

  use file_system

  implicit none

  type(File) :: main
  type(File) :: ninja

  if (.not. create_directory('generated')) stop 1
  main = File('generated/main.f90')
  if (.not. main%write_line('program generate')) stop 1
  if (.not. main%write_line('end program')) stop 1
  ninja = File('generated/build.ninja')

end program generate
