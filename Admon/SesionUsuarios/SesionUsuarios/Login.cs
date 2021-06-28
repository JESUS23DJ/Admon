using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using SesionUsuarios.Datos;

namespace SesionUsuarios
{
    public partial class Login : Form
    {
        public Login()
        {
            InitializeComponent();
        }

        private void btnIngresar_Click(object sender, EventArgs e)
        {
            int idusuario_esperado = Proc_Usuario.Logeo(txtUsuario.Text, txtPass.Text);


            if (idusuario_esperado != 0)
            {
                this.Hide();

                MDI_Menu mdi = new MDI_Menu(idusuario_esperado);
                mdi.Show();
            }
            else
            {

                MessageBox.Show("Usuario no encontrado");
            }

        }
    }
}
