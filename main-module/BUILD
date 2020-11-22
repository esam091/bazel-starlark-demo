load('//script:java.bzl', 'my_java_library')

my_java_library(
    name = 'main-module',
    srcs = glob(['**/*.java']),
    deps = ['//library-module:library']
)