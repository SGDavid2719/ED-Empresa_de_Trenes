with Ada.Text_IO; use Ada.Text_IO;
with dTren;

procedure Main is

   -- Es de tipo generico para poder modificar el tamaño del hashing abierto
   package dt is new dTren (maxTrenes => 31); use dt;

   c                   : cTrenes;
   t                   : tcodigo;
   contadorLocomotoras : Integer;
   contadorVagones     : Integer;

   -- Metodo que genera un codigo alfanumerico a partir del numero del contador introducido por parametro y su tipo
   procedure generaCodigo(contador: in out Integer; tNuevo: out tcodigo; tipo: in Character) is
      num : Integer;
   begin
      num := contador;
      for i in key_index loop
         if i=1 then
            -- El primer caracter debe ser 'V' si vagon y 'L' si locomotora
            tNuevo(1):= tipo;
         else
            -- Si puede dividirse entre 10
            if num>0 then
               -- Calcula el caracter que corresponde
               tNuevo(i):= Character(Integer'Image(num mod 10)(2));
               num:=num/10;
            else
               tNuevo(i):='0';
            end if;
         end if;
      end loop;
      -- Incrementa el numero de existencias
      contador := contador+1;
   end generaCodigo;

begin

   -- Inicializar
   Put_Line("INICIALIZAMOS LA ESTRUCTURA");
   vacio(c);
   contadorLocomotoras := 0;
   contadorVagones := 0;
   Put_Line(" ");

   -- Locomotora 1
   Put_Line("CREAMOS UNA LOCOMOTORA");
   generaCodigo(contadorLocomotoras, t, 'L');
   aparcaLocomotora(c , t);
   Put_Line(" ");

   -- Locomotora 2
   Put_Line("CREAMOS OTRA LOCOMOTORA");
   generaCodigo(contadorLocomotoras, t, 'L');
   aparcaLocomotora(c , t);
   Put_Line(" ");

   -- Locomotora 3
   Put_Line("CREAMOS OTRA LOCOMOTORA");
   generaCodigo(contadorLocomotoras, t, 'L');
   aparcaLocomotora(c , t);
   Put_Line(" ");

   -- Vagones
   Put_Line("CREAMOS LOS VAGONES");
   for i in 1..6 loop
      generaCodigo(contadorLocomotoras, t, 'V');
      aparcaVagon(c, t, i);
   end loop;
   Put_Line(" ");

   -- Crear tren 1
   creaTren(c, t, 3);
   Put("CREAMOS EL TREN CON CODIGO ");
   for i in key_index loop
      Put(t(i));
   end loop;
   Put_Line(" ");
   Put_Line(" ");

   -- Crear tren 2
   creaTren(c, t, 2);
   Put("CREAMOS EL TREN CON CODIGO ");
   for i in key_index loop
      Put(t(i));
   end loop;
   Put_Line(" ");
   Put_Line(" ");

   -- Crear tren 3
   creaTren(c, t, 1);
   Put("CREAMOS EL TREN CON CODIGO ");
   for i in key_index loop
      Put(t(i));
   end loop;
   Put_Line(" ");
   Put_Line(" ");

   -- Listamos los trenes
   Put_Line("LISTAMOS LOS TRENES");
   listarTrenes(c);
   Put_Line(" ");

   -- Consultamos un tren
   Put_Line("CONSULTAMOS UN TREN");
   consultaTren(c, t);
   Put_Line(" ");

   -- Desmantelamos un tren
   Put_Line("DESMANTELAMOS UN TREN");
   desmantelarTren(c);
   Put_Line(" ");

   -- Listamos de nuevo los trenes
   Put_Line("LISTAMOS LOS TRENES");
   listarTrenes(c);
   Put_Line(" ");
end Main;
