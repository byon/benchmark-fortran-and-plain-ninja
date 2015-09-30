program generate

  use file_system

  implicit none

  type(File) :: main

  if (.not. create_directory('generated')) stop 1
  main = File('generated/main.f90')

end program generate
