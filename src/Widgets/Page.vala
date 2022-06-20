/* Page.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public abstract class Page : Adw.Bin, Gtk.Buildable {
        public string title {
            get {
                return status_page.title;
            }
            set {
                status_page.title = value;
            }
        }

        public string? _short_title = null;
        public string? short_title {
            get {
                if (_short_title == null)
                    return title;
                return _short_title;
            }
            set {
                _short_title = value;
            }
        }

        public string description {
            get {
                return status_page.description;
            }
            set {
                status_page.description = value;
            }
        }

        public string icon_name {
            get {
                return status_page.icon_name;
            }
            set {
                status_page.icon_name = value;
            }
        }

        private Adw.StatusPage status_page = new Adw.StatusPage ();
        private Adw.Clamp clamp = new Adw.Clamp ();
        public Xdp.Portal portal { get; construct set; }

        construct {
            child = status_page;
            status_page.child = clamp;
        }

        public void add_child (Gtk.Builder builder, Object child, string? type) {
            return_if_fail (child is Gtk.Widget);
            clamp.child = (Gtk.Widget) child;
        }

        public abstract void callback (GLib.Object? obj, AsyncResult res);
    }
}
