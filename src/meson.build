libportal_vala_sample_sources = [
  'main.vala',
  'Application.vala',
  'Widgets/Window.vala',
 ]

libportal_vala_sample_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1'),
  dependency('libportal'),
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

gnome = import('gnome')

libportal_vala_sample_sources += gnome.compile_resources('libportal_vala_sample-resources',
  'libportal_vala_sample.gresource.xml',
  c_name: 'libportal_vala_sample'
)

executable('libportal-vala-sample', libportal_vala_sample_sources,
  vala_args: [
    meson.project_source_root() + '/src/vapi/config.vapi',
    '--target-glib=2.50',
  ],
  dependencies: libportal_vala_sample_deps,
  install: true,
)
