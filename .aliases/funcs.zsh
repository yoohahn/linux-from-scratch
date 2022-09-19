# Convert to gif
to_gif(){
  ffmpeg -i $1 -loop 0 -c:v gif -f gif $2
}
gitcommit(){
  git commit -am "$1: ${@:2}"
  git push -u
}

# SSH
sshtmp() {
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
}

nugetAuth(){
  dotnet nuget remove source github 1> /dev/null
  dotnet nuget remove source $ORGANIZATION 1> /dev/null
  X_ME=`whoami`
  #dotnet nuget add source https://nuget.pkg.github.com/GITHUB_ORG/index.json -n $ORGANIZATION -u $X_ME -p ${GH_TOKEN} --store-password-in-clear-text
}
