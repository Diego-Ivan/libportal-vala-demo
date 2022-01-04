project('libportal-vala-sample', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

app_id = 'io.github.diegoivanme.libportal_vala_sample'

i18n = import('i18n')



subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
