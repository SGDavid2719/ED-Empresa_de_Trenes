with dpila;
with dcola;
with davl;
with d_open_hash;

generic
   maxTrenes: Positive;
package dTren is

   type cTrenes is limited private;
   
   -- Codigo alfanumérico
   subtype key_component is Character range '0' .. 'Z';
   subtype key_index     is positive range 1..8;
   type tcodigo          is array(key_index) of key_component;
   
   -- Excepciones
   aparcamiento_locomotoras_completo : exception;
   aparcamiento_vagones_completo     : exception;
   locomotoras_agotadas              : exception;
   vagones_agotadas                  : exception;
   inventario_trenes_completo        : exception;
   tren_no_existe                    : exception;
   
   -- Prepara la estructura de la compañia de trenes para trabajar con ella
   procedure vacio(cia: out cTrenes);
   -- Da de alta una nueva locomotora con codigo k y la aparca
   procedure aparcaLocomotora(cia: in out cTrenes; k: in tcodigo);
   -- Da de alta un nuevo vagon con codigo k y peso pmax y lo aparca 
   procedure aparcaVagon(cia: in out cTrenes; k: in tcodigo; pmax: in integer);
   -- Lista todos los trenes que se encuentran montados ordenados ascendentemente por su peso de carga maxima acumulado
   procedure listarTrenes(cia: in cTrenes);
   -- Crear un nuevo tren a partir de una locomotora libre con codigo k y el numero num-vagones indicado de vagones libres 
   procedure creaTren(cia: in out cTrenes; t: out tcodigo; num_vagones: in Integer);
   -- Debe mostrar la información del tren con el c´odigo identificativo t
   procedure consultaTren(cia: in cTrenes; t: in tcodigo);
   -- Desmantela el tren con el menor peso de carga m´axima acumulada
   procedure desmantelarTren(cia: in out cTrenes);
   
private
   
   -- Locomotora y cola de locomotoras
   type locomotora is record
      codigoLocomotora : tcodigo;
   end record;
   
   type pLocomotora is access locomotora;
   
   package colaLocomotora is new dcola (elem => pLocomotora);
   use colaLocomotora;
   
   -- Vagon y pila de vagones
   type vagon is record
      codigoVagon : tcodigo;
      pmax        : Integer;
   end record;
   
   type pVagon is access vagon;
   
   package pilaVagon is new dpila (elem => pVagon);
   use pilaVagon;
   
   -- Tren, arbol avl de trenes y hashing abierto de trenes
   type nodo;
   type pnodo is access nodo;
   type nodo is record
      x: pVagon;
      sig: pnodo;
   end record;
   
   type tren is record
      locomotoraTren : pLocomotora;
      vagonesTren    : pnodo;
   end record;
   
   type pTren is access tren;
   
   -- Arbol avl ordenado por peso acumulado con puntero al tren
   function menor (p1, p2 : in Integer) return boolean;
   function major (p1, p2 : in Integer) return boolean;
   
   package avlTren is new davl (key => Integer, item => pTren, "<" => menor, ">" => major);
   use avlTren;
   
   -- Hashing abierto por matricula con puntero al tren
   function hashOperation (k: in tcodigo; b: in positive) return natural;
   function igual (p1, p2 : in tcodigo) return boolean;
   
   package openHashTren is new d_open_hash (key => tcodigo, item => pTren, hash => hashOperation, "=" => igual, size => maxTrenes);
   use openHashTren;

   -- CTrenes, estructura completa
   type cTrenes is record
      cola_Locomotoras : colaLocomotora.cola;
      pila_Vagones     : pilaVagon.pila;
      arbol_Trenes     : avlTren.conjunto;   
      openHash_Trenes  : openHashTren.conjunto;
   end record;
   
end dTren;
