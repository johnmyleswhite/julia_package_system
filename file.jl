function dir(directory_name)
  map(chomp, readlines(`ls $directory_name`))
end

function dir()
  dir(".")
end

#dir("/")
#dir()

function basename(path)
  os_separator = "/"
  components = split(path, os_separator)
  k = length(components)
  strcat(join(components[1:(k - 1)], os_separator), os_separator)
end

#basename("/Users/johnmyleswhite")

function dirname(path)
  os_separator = "/"
  components = split(path, os_separator)
  k = length(components)
  join(components[1:(k - 1)], os_separator)
end

#dirname("/Users/johnmyleswhite")

function file_path(components...)
  os_separator = "/"
  join(components, os_separator)
end

#file_path("Users", "johnmyleswhite")

function path_expand(path)
  chomp(readlines(`bash -c "echo $path"`)[1])
end

#path_expand("~/")

function file_copy(source, destination)
  run(`cp $source $destination`)
end

function file_create(filename)
  run(`touch $filename`)
end

function file_remove(filename)
  run(`rm $filename`)
end

function path_rename(old_pathname, new_pathname)
  run(`mv $old_pathname $new_pathname`)
end

function dir_create(directory_name)
  run(`mkdir $directory_name`)
end

function file_exists(filename)
  if length(readlines(`ls $filename`)) != 0
    true
  else
    false
  end
end

function tempdir()
  chomp(readall(`mktemp -d -t tmp`))
end

function tempfile()
  chomp(readall(`mktemp -t tmp`))
end

function download_file(url)
  filename = tempfile()
  run(`curl -o $filename $url`)
  new_filename = strcat(filename, ".tar.gz")
  path_rename(filename, new_filename)
  new_filename
end
