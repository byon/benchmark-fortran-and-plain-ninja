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
  if (.not. ninja%write_line('configuration = debug')) stop 1
  if (.not. ninja%write_line('output_directory = $builddir/$configuration')) stop 1
  if (.not. ninja%write_line('fflags = ' // compilation_options())) stop 1

contains

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
         '/Qlocation,link,"C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin"'
  end function

end program generate
