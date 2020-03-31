require_relative "../support/prueba"
require_relative "../support/caso"

class MuertesTest
  include Caso

  def initialize(source = "muertes.json")
    @source = File.join(DIRECTORY, source)
  end

  def casos(&block)
    @command = "open #{@source} "\
               " | where created_at == #{@fecha} "\
               " | get total "\
               " | sum "\
               " | echo $it"
    probar!(&block)
  end

  def provincias_ingresadas(&block)
    @command = "open #{@source}                  "\
               " | where created_at == #{@fecha} "\
               " | where total > 0 "\
               " | count "\
               " | echo $it"
    probar!(&block)
  end
  
  def provincias_sin_ingresar(&block)
    @command = "open #{@source} "\
               " | where created_at == #{@fecha} "\
               " | where total == 0 "\
               " | count "\
               " | echo $it"
    probar!(&block)
  end
end

describe "Muertes registradas" do
  require_relative "../criterios"

  Criterios.para(:muertes).each do |(de_informe, fecha, spec)|
    muertes_totales = spec[:muertes]
    ingresadas_totales =  spec[:provincias_ingresadas]
    sin_ingresar_totales = spec[:provincias_sin_ingresar]

    nombre, numero, hora = de_informe.to_s.split('_')
    ruta = File.join(
      File.expand_path('../../../../informes/', __FILE__),
      [nombre, numero, fecha.gsub('/', '_'), hora].join('-') + ".pdf"
    )

    context "informe: #{ruta}..." do
      datos = MuertesTest.para(fecha)

      it "Verificando casos.." do
        datos.casos do |total|
          expect(total).to be(muertes_totales)
        end
      end

      it "Verificando provincias con información.." do
        datos.provincias_ingresadas do |total|
          expect(total).to be(ingresadas_totales)
        end
      end 

      it "Verificando provincias sin información.." do
        datos.provincias_sin_ingresar do |total|
          expect(total).to be(sin_ingresar_totales)
        end
      end

      it "Verificando que todas los provincias existen.." do
        expect(ingresadas_totales + sin_ingresar_totales).to be(24)
      end
    end
  end
end
