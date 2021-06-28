using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SesionUsuarios.Datos;
using SesionUsuarios.Modelo;

namespace SesionUsuarios
{
    public partial class MDI_Menu : Form
    {
        private int id_usuario;

        public MDI_Menu(int idusuario_esperado = 0)
        {
            InitializeComponent();

            id_usuario = idusuario_esperado;
        }

        private void MDI_Menu_Load(object sender, EventArgs e)
        {
            List<Modelo.Menu> Permisos_Esperados = Proc_Usuario.ObtenerPermisos(id_usuario);

            MenuStrip MiMenu = new MenuStrip();

            //ITERAMOS EL MENU DE NUESTRA LISTA
            foreach (Modelo.Menu objMenu in Permisos_Esperados)
            {

                ToolStripMenuItem menuPadre = new ToolStripMenuItem(objMenu.Nombre);
                menuPadre.TextImageRelation = TextImageRelation.ImageAboveText;

                string rutaImagen = Path.GetFullPath(Path.Combine(Application.StartupPath, @"../../") + @objMenu.Icono);

                menuPadre.Image = new Bitmap(rutaImagen);
                menuPadre.ImageScaling = ToolStripItemImageScaling.None;

                //ITERAMOS LOS SUBMENUS DENTRO DE OBJMENU
                foreach (SubMenu objSubMenu in objMenu.ListaSubMenu)
                {

                    ToolStripMenuItem menuHijo = new ToolStripMenuItem(objSubMenu.NombreSub);


                    menuPadre.DropDownItems.Add(menuHijo);
                }


                MiMenu.Items.Add(menuPadre);
            }


            //AGREGAMOS EL CONTROL AL FORMULARIO
            this.MainMenuStrip = MiMenu;
            Controls.Add(MiMenu);

        }


    }
}

