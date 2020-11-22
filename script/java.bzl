load("@bazel_skylib//lib:paths.bzl", "paths")

MyJavaInfo = provider(
    fields = ['jar_files']
)

def file_to_path(file):
    return file.path

def _my_java_library_impl(ctx):
    java_files = ctx.files.srcs
    
    output_files = []
    jar_dependencies = []

    deps = ctx.attr.deps

    for dep in deps:
        jar_dependencies += dep[MyJavaInfo].jar_files
    
    #only used for getting base directory
    dummy = ctx.actions.declare_file('dummy')

    for input_file in java_files:
        split_paths = input_file.path.split('/')
        split_paths[0] = 'classes'

        output_path = paths.replace_extension(
            paths.join("", *split_paths), 
            '.class'
        )
        
        absolute_output_path = ctx.actions.declare_file(output_path)

        print("result", absolute_output_path.path)
        output_files.append(absolute_output_path)


    root_dir = paths.normalize(paths.join(dummy.path, '..', 'classes'))
    ctx.actions.run_shell(
        outputs = [dummy],
        command = ['touch', dummy.path]
    )

    args = ctx.actions.args()
    args.add('-d', root_dir)
    args.add_joined('-cp', jar_dependencies, join_with=':', map_each=file_to_path)
    args.add_all(java_files)

    ctx.actions.run_shell(
        inputs = java_files + jar_dependencies,
        outputs = output_files,
        command = 'javac $@',
        arguments = [args]
    )

    jar_file = ctx.actions.declare_file(ctx.attr.name + '.jar')

    jar_args = ctx.actions.args()
    jar_args.add('cf', jar_file)
    jar_args.add('-C', root_dir)
    jar_args.add('.')

    ctx.actions.run_shell(
        inputs = output_files + jar_dependencies,
        outputs = [jar_file],
        command = 'jar $@',
        arguments = [jar_args]
    )

    return [
        DefaultInfo(
            files = depset(output_files + [jar_file])
        ),
        MyJavaInfo(
            jar_files = [jar_file]
        )
    ]

my_java_library = rule(
    implementation = _my_java_library_impl,
    attrs = {
        'srcs': attr.label_list(
            allow_empty = False,
            mandatory =  True,
            allow_files = ['.java']
        ),
        'deps': attr.label_list(
            allow_empty = True,
            mandatory = False,
            providers = [MyJavaInfo]
        )
    }
)

