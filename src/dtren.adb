with ada.Numerics.Discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;
with ADA.Integer_Text_IO; use ADA.Integer_Text_IO;
with Ada.Containers; use Ada.Containers;
with Ada.Strings.Hash;

package body dTren is
   
   procedure vacio(cia: out cTrenes) is
   begin
      -- Inicializamos la cola de locomotoras
      cvacia(cia.cola_Locomotoras);
      -- Inicializamos la pila de vagones
      pvacia(cia.pila_Vagones);
      -- Inicializamos el arbol balanceado de trenes
      cvacio(cia.arbol_Trenes);
      -- Inicializamos el hashing abierto de trenes
      cvacio(cia.openHash_Trenes);
   end vacio;
   
   
   procedure aparcaLocomotora(cia: in out cTrenes; k: in tcodigo) is
      l : pLocomotora;
   begin
      -- Reservamos espacio
      l := new locomotora;
      -- Guardamos el codigo para darla de alta
      l.all.codigoLocomotora := k;
      -- Aparcamos la locomotora 
      poner(cia.cola_Locomotoras, l);
   exception
      -- Aparcamiento de locomotoras completo
      when colaLocomotora.espacio_desbordado => raise aparcamiento_locomotoras_completo;
   end aparcaLocomotora;
   
   
   procedure aparcaVagon(cia: in out cTrenes; k: in tcodigo; pmax: in integer) is 
      v : pVagon;   
   begin 
      -- Reservamos espacio
      v := new vagon;
      -- Guardamos el codigo y el peso para darlo de alta
      v.all.codigoVagon := k;
      v.all.pmax := pmax;  
      -- Aparcamos el vagon
      empila(cia.pila_Vagones, v); 
   exception
         -- Aparcamiento de vagones completo
      when pilaVagon.espacio_desbordado => raise aparcamiento_vagones_completo;
   end aparcaVagon;
   
   
   procedure listarTrenes(cia: in cTrenes) is
      tr         : pTren;
      v          : pVagon;
      t          : tcodigo;
      pAcumulado : Integer;
      it         : iterator;
      r          : pnodo;
   begin
      -- Preparamos el iterador
      first(cia.arbol_Trenes, it);
      -- Iteramos sobre todo el arbol avl
      while is_valid(it) loop
         -- Obtenemos el tren con menor peso
         get(cia.arbol_Trenes, it, pAcumulado, tr);
         -- Obtenemos el codigo de la locomotora y lo cambiamos por una 'T' inicial
         t := tr.all.locomotoraTren.all.codigoLocomotora;
         t(1) := 'T';
         -- Consultamos el codigo del tren
         Put("Codigo del tren                    : ");
         for i in key_index loop
            Put(t(i));
         end loop;
         Put_Line(" ");
         -- Consultamos el peso acumulado del tren
         Put_Line("Peso maximo de carga acumulado     :" & Integer'Image(pAcumulado));
         -- Consultamos el codigo de la locomotora del tren
         Put("Codigo de la locomotora            : ");
         for i in key_index loop
            Put(tr.all.locomotoraTren.all.codigoLocomotora(i));
         end loop;
         Put_Line(" ");
         -- Consultamos los vagones del tren
         r := tr.all.vagonesTren;
         while r /= null loop
            v := r.all.x;
            -- Consultamos el codigo del vagon del tren
            Put("Codigo del vagon                   : ");
            for i in key_index loop
               Put(v.all.codigoVagon(i));
            end loop;
            Put_Line(" ");
            -- Consultamos el peso del vagon
            Put_Line("Peso del vagon                     :" & Integer'Image(v.all.pmax));
            -- Pasamos al siguiente vagon
            r := r.all.sig;
         end loop;
         -- Siguiente nodo del arbol
         next(cia.arbol_Trenes, it);
         Put_Line(" ");
      end loop;      
   end listarTrenes;
   
   
   procedure creaTren(cia : in out cTrenes; t: out tcodigo; num_vagones: in Integer) is   
      l          : pLocomotora;
      v          : pVagon;
      tr         : pTren;
      pAcumulado : Integer;
      r          : pnodo;
   begin 
      -- Reservamos espacio
      tr := new tren;
      pAcumulado := 0;
      -- Cogemos la primera locomotora libre y la borramos de la cola
      l := coger_primero(cia.cola_Locomotoras);
      borrar_primero(cia.cola_Locomotoras);
      tr.all.locomotoraTren := l;
      -- Cogemos num_vagones de los vagones libres
      for i in 1..num_vagones loop
         -- Cogemos el primer vagon libre y lo borramos de la pila
         v := cima(cia.pila_Vagones);
         desempila(cia.pila_Vagones);
         -- Actualizamos el peso acumulado del tren con el nuevo vagon 
         pAcumulado := pAcumulado + v.all.pmax;
         -- Introducimos el vagón detrás de la locomotora
         r := new nodo;
         r.all := (v, tr.all.vagonesTren);
         tr.all.vagonesTren := r;
      end loop;
      -- Obtenemos el codigo de la locomotora y lo cambiamos por una 'T' inicial
      t := l.all.codigoLocomotora;
      t(1) := 'T';
      -- Metemos el tren en el arbol avl
      poner(cia.arbol_Trenes, pAcumulado, tr);
      -- Metemos el tren en el hashing abierto
      poner(cia.openHash_Trenes, t, tr);
   exception
      -- No quedan locomotoras libres
      when colaLocomotora.mal_uso => raise locomotoras_agotadas;
      -- No quedan vagones libres
      when pilaVagon.mal_uso => raise vagones_agotadas;
      -- No queda espacio para almacenar el tren montado
      when avlTren.espacio_desbordado => raise inventario_trenes_completo;
      when openHashTren.espacio_desbordado => raise inventario_trenes_completo;
   end creaTren;
   
   
   procedure consultaTren(cia: in cTrenes; t: in tcodigo) is 
      tr   : pTren;
      v    : pVagon;
      r    : pnodo;
   begin
      -- Obtenemos el tren por su codigo
      consultar(cia.openHash_Trenes, t, tr);
      -- Consultamos el codigo del tren
      Put("Codigo del tren                    : ");
      for i in key_index loop
         Put(t(i));
      end loop;
      Put_Line(" ");
      -- Consultamos el codigo de la locomotora del tren
      Put("Codigo de la locomotora            : ");
      for i in key_index loop
         Put(tr.all.locomotoraTren.all.codigoLocomotora(i));
      end loop;
      Put_Line(" ");
      -- Consultamos los vagones del tren
      r := tr.all.vagonesTren;
      while r /= null loop
         v := r.all.x;
         -- Consultamos el codigo del vagon del tren
         Put("Codigo del vagon                   : ");
         for i in key_index loop
            Put(v.all.codigoVagon(i));
         end loop;
         Put_Line(" ");
         -- Consultamos el peso del vagon
         Put_Line("Peso del vagon                     :" & Integer'Image(v.all.pmax));
         -- Pasamos al siguiente vagon
         r := r.all.sig;
      end loop;
   exception
      -- Tren con codigo t no existe en el inventario de trenes montados
      when openHashTren.no_existe => raise tren_no_existe;
   end consultaTren;
   
   
   procedure desmantelarTren(cia: in out cTrenes) is 
      l          : pLocomotora;
      v          : pVagon;
      tr         : pTren;
      it         : iterator;
      pAcumulado : Integer;
      t          : tcodigo;
   begin
      -- Preparamos el iterador
      first(cia.arbol_Trenes, it);
      -- Obtenemos el tren con menor peso
      get(cia.arbol_Trenes, it, pAcumulado, tr);
      pAcumulado := 0;
      -- Recorremos los vagones los vagones
      while tr.all.vagonesTren /= null loop
         -- Recogemos la informacion del vagon
         v := tr.all.vagonesTren.all.x;
         pAcumulado := pAcumulado + v.all.pmax;
         -- Desenganchamos el vagon
         tr.all.vagonesTren.all.x := null;
         -- Aparcamos el vagon
         empila(cia.pila_Vagones, v);
         -- Pasamos al siguiente vagon
         tr.all.vagonesTren := tr.all.vagonesTren.all.sig;
      end loop;
      -- Aparcamos la locomotora
      l := tr.all.locomotoraTren;
      poner(cia.cola_Locomotoras, l);
      t := tr.all.locomotoraTren.all.codigoLocomotora;
      t(1) := 'T';
      -- Eliminamos el tren del inventario de trenes
      borrar(cia.arbol_Trenes, pAcumulado);
      borrar(cia.openHash_Trenes, t);      
   exception
      -- No hay ningun tren montado
      when avlTren.no_existe => raise tren_no_existe;
      when openHashTren.no_existe => raise tren_no_existe;
      -- Aparcamiento de vagones completo
      when pilaVagon.espacio_desbordado => raise aparcamiento_vagones_completo;
      -- Aparcamiento de locomotoras completo
      when colaLocomotora.espacio_desbordado => raise aparcamiento_locomotoras_completo;
   end desmantelarTren;
   
   -- METODOS PARA EL ARBOLY EL OPEN HASH
   
   -- Funcion para definir la prioridad "<" del AVL
   function menor (p1, p2 : in Integer) return boolean is
   begin
      return p1 < p2;
   end menor;
   
   
   -- Funcion para definir la prioridad ">" del AVL
   function major (p1, p2 : in Integer) return boolean is
   begin
      return p1 > p2;
   end major;
   
   
   -- Funcion para realizar la operacion de hash
   function hashOperation (k: in tcodigo; b: in positive) return natural is
      h: Ada.Containers.Hash_Type;
      s: natural;
      str : string(1..8);
      i : Integer;
   begin
      i := 1;
      -- Procedimiento para convertir de array de key_component a string
      for j in key_index loop
         str(i) := k(j);
         i := i+1;
      end loop;
      h:= Ada.Strings.Hash(str(1..8)) mod Hash_Type(b);
      s:= Natural(h);
      return s;
   end hashOperation;
   
   
   -- Funcion igual
   function igual(p1, p2: in tcodigo) return Boolean is
   begin
      return p1=p2;
   end igual;
   
end dTren;
