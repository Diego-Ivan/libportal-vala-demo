/* ColorViewer.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class ColorViewer : Adw.Bin {
        private Gdk.RGBA _color;
        private Gtk.CssProvider css_provider;
        public Gdk.RGBA color {
            get {
                return _color;
            }

            set {
                _color = value;
                css_provider.load_from_data ((uint8[])
                    "* { background-color: %s; }".printf (value.to_string ())
                );
            }
        }
        public ColorViewer () {
            Object (
                css_name: "colorviewer"
            );
        }

        class construct {
            set_css_name ("colorviewer");
        }

        construct {
            css_provider = new Gtk.CssProvider ();
            get_style_context ().add_provider (
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            color = {
                0,
                0,
                0,
                (float) 1.0
            };
        }
    }
}
