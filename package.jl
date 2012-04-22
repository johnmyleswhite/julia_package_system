load("file.jl")

function create_package()
  dir_create("doc")
  dir_create("examples")
  dir_create("src")
  dir_create("tests")
  file_create(file_path("src", "init.jl"))
  file_create("README")
  file_create("TODO")
  file_create("METADATA")
end

create_package() # Check that this produces expected files.

function update_packages()
  # NO-OP
  # Should download new copy of packages.csv
end

update_packages() # Does nothing at present.

function available_packages()
  csvread(path_expand("~/.julia/packages.csv"))
end

available_packages() # Returns a 2x2 array.

function installed_packages()
  package_directory = path_expand("~/.julia/packages")
  map(chomp, readlines(`ls $package_directory`))
end

installed_packages() # List all packages installed on the system.

# Package management
# Store list of files and their load time
global _jl_file_list = HashTable{ByteString, Float64}()

function require(filename::ByteString)
  if ! has(_jl_file_list, filename)
    load(filename)
    _jl_file_list[filename] = 0.0
  end
end

require("extras/Rmath.jl")
require("extras/Rmath.jl")

function load_package(package_name)
  require(path_expand("~/.julia/packages/$package_name/src/init.jl"))
  # Is there a mechanism to force a load call within a load call
  # to use the working directory of the current caller rather than
  # the root caller?
end

load_package("toy")
fun1(2) # From the toy package.

function find_packages(search_query)
  packages = available_packages()
  
  results = []
  
  # If query is string, find all packages that contain that substring.
  # Not yet implemented.
  
  # If query is Regex, find all packages that match regex.  
  if typeof(search_query) != Regex
    error("ERROR: Only regex search is currently supported by find_package()")
  else
    for i = 1:size(packages, 1)
      if matches(search_query, packages[i, 1])
        results = [results, packages[i, 1]]
      end
    end    
  end
  
  results
end

find_packages(r"t")
find_packages(r"to")

function package_url(author_name, package_name)
  "https://nodeload.github.com/$(author_name)/$(package_name)/tarball/master"
end

package_url("johnmyleswhite", "stats.jl")

# Download tarball from GitHub.
function download_package(package_url)
  download_file(package_url)
end

f = download_package(package_url("johnmyleswhite", "stats.jl"))

function store_package(package_name, tarball_location)
  # Move file to standard location.
  source = tarball_location
  destination = strcat(path_expand("~/.julia/tmp/"), package_name, ".tar.gz")
  path_rename(source, destination)
  
  # Untar the newly moved package into a temporary directory inside .julia.
  # This makes it easier to hack a way to remove tarball and know the
  # location of the extracted contents.
  old_wd = getcwd()
  setcwd(path_expand("~/.julia/tmp"))
  run(`tar xfz $destination`)
  file_remove(destination)
  final_source = dir()[1]
  final_destination = strcat(path_expand("~/.julia/packages/"), package_name)
  path_rename(final_source, final_destination)
  
  # Need to restore old working directory.
  setcwd(old_wd)
end

store_package("stats.jl", f)

function install_package(package_name)
  # Search through package metadata for a match.
  packages = available_packages()
  
  author_name = None
  for i = 1:size(packages, 1)
    if packages[i, 1] == package_name
      author_name = packages[i, 2]
      break
    end
  end
  
  if author_name == None
    error("ERROR: No package available called $package_name")
  end
  
  url = package_url(author_name, package_name)
  
  tarball_location = download_package(url)
  
  store_package(package_name, tarball_location)
  
  println("Successfully installed $package_name")
end

install_package("stats.jl")
