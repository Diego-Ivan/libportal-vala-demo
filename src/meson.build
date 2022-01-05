subdir('resources')

libportal_vala_sample_code_sources = files (
  'main.vala',
  'Application.vala',
  'Widgets/Window.vala',
  'Widgets/Page.vala',
  'Widgets/Pages/Account.vala',
)

libportal_vala_sample_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1'),
  dependency('libportal'),
  dependency('libportal-gtk4'),
]

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('G_LOG_DOMAIN', 'XdpVala-Sample')
conf.set_quoted('VERSION', meson.project_version())
configure_file(output: 'config.h', configuration: conf)

add_project_arguments(
    '-include', 'config.h',
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

libportal_vala_sample_sources = [
  libportal_vala_sample_code_sources,
  libportal_vala_sample_resources,
]

executable('libportal-vala-sample', libportal_vala_sample_sources,
  include_directories: [
    include_directories('.')
  ],
  vala_args: [
    '--gresources', libportal_vala_sample_resource_files,
    meson.project_source_root() + '/src/vapi/config.vapi',
    '--vapidir', meson.current_source_dir(),
    '--target-glib=2.50',
  ],
  dependencies: libportal_vala_sample_deps,
  install: true,
)
