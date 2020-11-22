set -e
mkdir -p build/library-module
javac -d build/library-module library-module/com/mylibrary/Foo.java library-module/com/mylibrary/MyLib.java
jar cf build/library-module.jar -C build/library-module com/mylibrary/Foo.class -C build/library-module com/mylibrary/MyLib.class

mkdir -p build/main-module
javac -d build/main-module -cp build/library-module.jar main-module/com/myapp/Main.java main-module/com/myapp/Person.java
jar cf build/main-module.jar -C build/main-module com/myapp/Person.class -C build/main-module com/myapp/Main.class
