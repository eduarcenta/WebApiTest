

using System.ComponentModel.DataAnnotations;

namespace EFWebApiTest.Contracts
{
    public sealed class ContractCliente : ContractPersona
    {
        [Required]
        public int IdCliente { get; set; }
        
        [Required]
        public string Contrasena { get; set; }
        
        [Required]
        public bool Estado { get; set; }

    } 

}
