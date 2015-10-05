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
  if (.not. ninja%write_line('ninja_required_version = 1.6.0')) stop 1
  if (.not. ninja%write_line('builddir = build')) stop 1

end program generate
