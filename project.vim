
Dist-Release=/home/yanick/work/perl-modules/Dist-Release CD=. {
 .gitignore
 distrelease.yml
 project.vim
 tags
 issues=issues {
  README.txt
 }
 pms=lib {
   Dist/Release.pm
   Dist/Release/Action.pm
   Dist/Release/Step.pm
   Dist/Release/Check/VCS/WorkingDirClean.pm
   Dist/Release/Action/CPANUpload.pm
   Dist/Release/Action/GenerateDistribution/Build.pm
 }
 script=script {
  distrelease
 }
 distribution=. {
    MANIFEST
    MANIFEST.SKIP
 }
}
