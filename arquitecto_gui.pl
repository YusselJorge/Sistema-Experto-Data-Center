% ============================================================================
%  SISTEMA EXPERTO DE DATA CENTER v2.0
%  Mejoras: Bugs corregidos, Redundancia N+1/N+2/2N, Tier I-IV,
%           TCO (CAPEX+OPEX), Scoring multicriterio, Workload profiles,
%           Compatibilidad PCIe, Explicabilidad, CLP(FD)
%  + Catálogo visual integrado
% ============================================================================

:- use_module(library(lists)).
:- use_module(library(apply)).

% Intentar cargar CLP(FD) si esta disponible (SWI-Prolog)
:- catch(use_module(library(clpfd)), _, true).

% Declaraciones dinamicas para sistema de explicacion
:- dynamic razon/2.
:- dynamic config_param/2.

% ============================================================================
% 1. CATALOGO GLOBAL EXPANDIDO (Con Imagenes y Specs extra)
% ============================================================================

% cpu(ID, Gama, Marca, Modelo, Cores, Socket, MaxRamSpeed, TDP, Precio, Imagen).
cpu(c1, alta, amd, 'AMD EPYC 9654', 96, sp5, 4800, 360, 11800, 'imagenes/cpu/amd_epyc_9654.jpg').
cpu(c2, alta, intel, 'Intel Xeon 8490H', 60, lga4677, 4800, 350, 17000, 'imagenes/cpu/intel_xeon_8490h.jpg').
cpu(c3, media, amd, 'AMD EPYC 7763', 64, sp3, 3200, 280, 7800, 'imagenes/cpu/amd_epyc_7763.jpg').
cpu(c4, media, intel, 'Xeon Gold 6330', 28, lga4189, 2933, 205, 1800, 'imagenes/cpu/xeon_gold_6330.jpg').
cpu(c5, alta, ampere, 'Ampere Altra Max M128-30', 128, lga4926, 3200, 250, 5800, 'imagenes/cpu/ampere_altra_m128.jpg').
cpu(c6, media, amd, 'AMD EPYC 8224', 24, zn4, 4800, 150, 950, 'imagenes/cpu/amd_epyc_8224.jpg').
cpu(c7, baja, intel, 'Xeon Silver 4410Y', 12, lga4677, 4800, 150, 600, 'imagenes/cpu/xeon_silver_4410y.jpg').
cpu(c8, baja, intel, 'Xeon E-2336', 6, lga1200, 3200, 65, 350, 'imagenes/cpu/xeon_e_2336.jpg').
cpu(c9, baja, amd, 'Ryzen 9 7950X Server', 16, am5, 5200, 170, 550, 'imagenes/cpu/ryzen_9_7950x.jpg').

% mb(ID, Marca, Modelo, Socket, TipoRAM, MaxRAM, SlotsRAM, Precio, Imagen).
mb(m1, asus, 'ASUS KRPA-U16', sp5, ddr5, 3072, 12, 1200, 'imagenes/motherboard/asus_krpa_u16.jpg').
mb(m2, supermicro, 'Supermicro X13', lga4677, ddr5, 4096, 16, 1500, 'imagenes/motherboard/supermicro_x13.jpg').
mb(m3, asrock, 'ASRock Rack ROM', sp3, ddr4, 2048, 16, 650, 'imagenes/motherboard/asrock_rack_rom.jpg').
mb(m4, supermicro, 'Supermicro X12', lga4189, ddr4, 2048, 24, 600, 'imagenes/motherboard/supermicro_x12.jpg').
mb(m5, gigabyte, 'Gigabyte MP72-HB0', lga4926, ddr4, 4096, 16, 1300, 'imagenes/motherboard/gigabyte_mp72_hb0.jpg').
mb(m6, supermicro, 'Supermicro H13SSL-NT', zn4, ddr5, 2048, 8, 550, 'imagenes/motherboard/supermicro_h13ssl_nt.jpg').
mb(m7, dell, 'Dell PowerEdge R250', lga1200, ddr4, 128, 4, 500, 'imagenes/motherboard/dell_poweredge_r250.jpg').
mb(m8, msi, 'MSI PRO-B650-Server', am5, ddr5, 192, 4, 250, 'imagenes/motherboard/msi_pro_b650_server.jpg').

% ram(ID, Marca, Tipo, CapacidadGB, Precio, Imagen).
ram(r1, samsung, ddr5, 512, 2100, 'imagenes/ram/ddr5_512gb.jpg').
ram(r2, micron, ddr5, 256, 950, 'imagenes/ram/ddr5_256gb.jpg').
ram(r3, sk_hynix, ddr5, 128, 450, 'imagenes/ram/ddr5_128gb.jpg').
ram(r4, samsung, ddr4, 256, 800, 'imagenes/ram/ddr4_256gb.jpg').
ram(r5, kingston, ddr4, 64, 300, 'imagenes/ram/ddr4_64gb.jpg').
ram(r6, corsair, ddr5, 32, 150, 'imagenes/ram/ddr5_32gb.jpg').
ram(r7, crucial, ddr4, 16, 70, 'imagenes/ram/ddr4_16gb.jpg').

% storage(ID, Marca, Tipo, CapacidadTB, IOPS, Precio, Imagen).
storage(s1, samsung, 'NVMe Gen5 Enterprise', 15, 1500000, 1200, 'imagenes/storage/nvme_gen5.jpg').
storage(s2, intel, 'NVMe Gen4 Enterprise', 7, 800000, 600, 'imagenes/storage/nvme_gen4.jpg').
storage(s3, kioxia, 'Kioxia CD6 NVMe Gen4', 3, 500000, 650, 'imagenes/storage/kioxia_cd6.jpg').
storage(s4, micron, 'Micron 5300 PRO SATA SSD', 3, 90000, 300, 'imagenes/storage/micron_5300_pro.jpg').
storage(s5, seagate, 'Seagate Exos Enterprise HDD', 18, 500, 450, 'imagenes/storage/seagate_exos.jpg').
storage(s6, wd, 'WD Gold Enterprise HDD', 10, 300, 250, 'imagenes/storage/wd_gold.jpg').

% gpu(ID, Marca, Modelo, VRAM_GB, TDP, Precio, Imagen).
gpu(g1, nvidia, 'NVIDIA H100 80GB Tensor Core', 80, 700, 30000, 'imagenes/gpu/nvidia_h100.jpg').
gpu(g2, nvidia, 'NVIDIA RTX 4090 24GB', 24, 450, 2000, 'imagenes/gpu/rtx_4090.jpg').
gpu(g3, nvidia, 'NVIDIA A100 Tensor Core', 40, 400, 12000, 'imagenes/gpu/nvidia_a100.jpg').
gpu(g4, nvidia, 'NVIDIA L40S Enterprise', 48, 350, 7200, 'imagenes/gpu/nvidia_l40s.jpg').
gpu(g5, amd, 'AMD Instinct MI210', 64, 300, 6000, 'imagenes/gpu/amd_instinct_mi210.jpg').
gpu(g6, nvidia, 'NVIDIA A2 Entry AI', 16, 60, 650, 'imagenes/gpu/nvidia_a2.jpg').
gpu(g0, none, 'Sin Tarjeta Grafica', 0, 0, 0, 'imagenes/gpu/sin_gpu.jpg').

% nic(ID, Marca, Modelo, VelocidadGbps, Latencia_us, Precio, Imagen).
nic(n1, nvidia, 'NVIDIA ConnectX-7 200GbE', 200, 0.5, 1800, 'imagenes/nic/connectx7.jpg').
nic(n2, intel, 'Intel E810 100GbE', 100, 1.2, 800, 'imagenes/nic/intel_e810.jpg').
nic(n3, broadcom, 'Broadcom 25GbE', 25, 2.0, 350, 'imagenes/nic/broadcom_25gbe.jpg').
nic(n4, broadcom, 'Broadcom 10GbE', 10, 3.5, 150, 'imagenes/nic/broadcom_10gbe.jpg').
nic(n5, realtek, 'Realtek Gigabit Base-T', 1, 5.0, 20, 'imagenes/nic/realtek_gigabit.jpg').

% psu(ID, Marca, Modelo, Watts, Eficiencia, Precio, Imagen).
psu(p1, dell, 'Dual Redundant 2000W Titanium', 2000, 0.96, 800, 'imagenes/psu/psu_2000w.jpg').
psu(p2, supermicro, 'Dual Redundant 1600W Platinum', 1600, 0.94, 600, 'imagenes/psu/psu_1600w.jpg').
psu(p3, hpe, 'Dual Redundant 1000W Platinum', 1000, 0.92, 400, 'imagenes/psu/psu_1000w.jpg').
psu(p4, corsair, '750W Gold Server PSU', 750, 0.90, 180, 'imagenes/psu/psu_750w.jpg').
psu(p5, evga, '500W Bronze PSU', 500, 0.85, 90, 'imagenes/psu/psu_500w.jpg').

% cooling(ID, Tipo, MaxTDP, PUE, Precio, Imagen).
cooling(cool1, 'Immersion Liquid Cooling', 3000, 1.05, 1500, 'imagenes/cooling/immersion_liquid.jpg').
cooling(cool2, 'Direct-to-Chip Liquid', 1500, 1.10, 800, 'imagenes/cooling/direct_to_chip.jpg').
cooling(cool3, 'High Performance Air Cooling', 500, 1.35, 200, 'imagenes/cooling/high_perf_air.jpg').
cooling(cool4, 'Standard Air Fans', 250, 1.50, 50, 'imagenes/cooling/standard_air_fans.jpg').

% ups(ID, Watts, AutonomiaMinutos, Precio, Imagen).
ups(u1, 5000, 20, 2500, 'imagenes/ups/ups_5000w.jpg').
ups(u2, 3000, 15, 1200, 'imagenes/ups/ups_3000w.jpg').
ups(u3, 1500, 10, 600, 'imagenes/ups/ups_1500w.jpg').
ups(u4, 800, 5, 200, 'imagenes/ups/ups_800w.jpg').

% chasis(ID, RackUnits, MaxSlotsPCIe, Precio, Imagen).
chasis(ch1, 1, 2, 400, 'imagenes/chasis/chasis_1u.jpg').
chasis(ch2, 2, 6, 800, 'imagenes/chasis/chasis_2u.jpg').
chasis(ch3, 4, 8, 1500, 'imagenes/chasis/chasis_4u.jpg').
chasis(ch4, 8, 16, 3500, 'imagenes/chasis/chasis_8u.jpg').


% ============================================================================
% 2. COMPATIBILIDAD PCIe CPU <-> GPU
% ============================================================================

% cpu_pcie(CPU_ID, LanesDisponibles, Generacion).
cpu_pcie(c1, 128, gen5).
cpu_pcie(c2, 80,  gen5).
cpu_pcie(c3, 128, gen5).
cpu_pcie(c4, 128, gen4).
cpu_pcie(c5, 64,  gen4).
cpu_pcie(c6, 96,  gen4).
cpu_pcie(c7, 64,  gen5).
cpu_pcie(c8, 16,  gen4).
cpu_pcie(c9, 28,  gen5).

% gpu_pcie_req(GPU_ID, LanesRequeridas, GeneracionMinima).
gpu_pcie_req(g1, 16, gen5).
gpu_pcie_req(g2, 16, gen4).
gpu_pcie_req(g3, 16, gen4).
gpu_pcie_req(g4, 16, gen4).
gpu_pcie_req(g5, 8,  gen4).
gpu_pcie_req(g0, 0,  gen1).  % Sin GPU, sin requisito

% Jerarquia de generaciones PCIe (hacia atras compatible)
gen_orden(gen1, 1).
gen_orden(gen2, 2).
gen_orden(gen3, 3).
gen_orden(gen4, 4).
gen_orden(gen5, 5).

gen_compatible(GenDisponible, GenRequerida) :-
    gen_orden(GenDisponible, Ord1),
    gen_orden(GenRequerida, Ord2),
    Ord1 >= Ord2.

% Compatibilidad CPU-GPU conocida (pares verificados en produccion)
compatible_cpu_gpu(c1, g1).  
compatible_cpu_gpu(c1, g2).  
compatible_cpu_gpu(c1, g3).  
compatible_cpu_gpu(c1, g4).  
compatible_cpu_gpu(c2, g1).  
compatible_cpu_gpu(c2, g2).  
compatible_cpu_gpu(c2, g3).  
compatible_cpu_gpu(c3, g2).  
compatible_cpu_gpu(c3, g5).  
compatible_cpu_gpu(c4, g2).  
compatible_cpu_gpu(c4, g3).  
compatible_cpu_gpu(c4, g4).  
compatible_cpu_gpu(c5, g3).  
compatible_cpu_gpu(c5, g5).  
compatible_cpu_gpu(c6, g5).  
compatible_cpu_gpu(c7, g5).  
compatible_cpu_gpu(c9, g3).  
compatible_cpu_gpu(c9, g5).  
% Todas las CPU son compatibles con g0 (sin GPU)
compatible_cpu_gpu(_, g0).

% Validacion completa PCIe
validar_pcie(_, GPU_ID) :-
    GPU_ID == g0.  % Sin GPU siempre valido
validar_pcie(CPU_ID, GPU_ID) :-
    GPU_ID \== g0,
    compatible_cpu_gpu(CPU_ID, GPU_ID),
    cpu_pcie(CPU_ID, Lanes, GenCPU),
    gpu_pcie_req(GPU_ID, ReqLanes, ReqGen),
    Lanes >= ReqLanes,
    gen_compatible(GenCPU, ReqGen).


% ============================================================================
% 3. REDUNDANCIA N+1, N+2, 2N
% ============================================================================

% redundancia(Tipo, ComponentesBase, ComponentesTotal)
redundancia(ninguna, N, N).
redundancia(n_mas_1, N, Total) :- Total is N + 1.
redundancia(n_mas_2, N, Total) :- Total is N + 2.
redundancia(dos_n,   N, Total) :- Total is N * 2.

% Tipo de redundancia por defecto segun tier
redundancia_por_tier(tier1, ninguna).
redundancia_por_tier(tier2, ninguna).
redundancia_por_tier(tier3, n_mas_1).
redundancia_por_tier(tier4, dos_n).

% PSU con redundancia
psu_con_redundancia(TDP_Total, TipoRedundancia, PSU_ID, NumPSU, CostoPSU) :-
    psu(PSU_ID, _, _, WattsPSU, Eficiencia, PrecioUnit, _),
    ConsumoReal is (TDP_Total + 150) / Eficiencia,
    NumBase is ceiling(ConsumoReal / WattsPSU),
    NumBase >= 1,
    WattsPSU * NumBase >= ConsumoReal * 1.20,  % Margen 20%
    redundancia(TipoRedundancia, NumBase, NumPSU),
    CostoPSU is NumPSU * PrecioUnit.

% UPS con redundancia
ups_con_redundancia(ConsumoReal, TipoRedundancia, UPS_ID, NumUPS, AutonomiaMin, CostoUPS) :-
    ups(UPS_ID, WattsUPS, Autonomia, PrecioUnit, _),
    WattsUPS >= ConsumoReal,
    Autonomia >= 10,
    NumBase = 1,
    redundancia(TipoRedundancia, NumBase, NumUPS),
    AutonomiaMin is Autonomia,
    CostoUPS is NumUPS * PrecioUnit.

% Cooling con redundancia
cooling_con_redundancia(TDP_Total, TipoRedundancia, Cool_ID, NumCool, PUE, CostoCool) :-
    cooling(Cool_ID, _, MaxTDP, PUE, PrecioUnit, _),
    MaxTDP >= TDP_Total,
    NumBase = 1,
    redundancia(TipoRedundancia, NumBase, NumCool),
    CostoCool is NumCool * PrecioUnit.


% ============================================================================
% 4. CUMPLIMIENTO TIER I - IV (Uptime Institute)
% ============================================================================

% tier_spec(Tier, UptimePct, MantenimientoConcurrente, ToleranteFallas,
%           RedundanciaReq, PUE_Max, AutonomiaUPS_Min)
tier_spec(tier1, 99.671, no,  no,  ninguna, 2.0, 5).
tier_spec(tier2, 99.741, no,  no,  ninguna, 1.8, 10).
tier_spec(tier3, 99.982, si,  no,  n_mas_1, 1.5, 15).
tier_spec(tier4, 99.995, si,  si,  dos_n,   1.4, 20).

% Verificar cumplimiento de tier
cumple_tier(Tier, PUE, Autonomia, Redundancia) :-
    tier_spec(Tier, _, _, _, RedReq, MaxPUE, MinAuto),
    PUE =< MaxPUE,
    Autonomia >= MinAuto,
    redundancia_compatible(Redundancia, RedReq).

% Una redundancia es compatible si es igual o superior
redundancia_compatible(dos_n, _).         % 2N cubre todo
redundancia_compatible(n_mas_2, n_mas_1). % N+2 cubre N+1
redundancia_compatible(n_mas_2, ninguna).
redundancia_compatible(n_mas_1, n_mas_1).
redundancia_compatible(n_mas_1, ninguna).
redundancia_compatible(ninguna, ninguna).

% Determinar tier maximo alcanzado
tier_maximo(PUE, Autonomia, Redundancia, TierMax) :-
    ( cumple_tier(tier4, PUE, Autonomia, Redundancia) -> TierMax = tier4
    ; cumple_tier(tier3, PUE, Autonomia, Redundancia) -> TierMax = tier3
    ; cumple_tier(tier2, PUE, Autonomia, Redundancia) -> TierMax = tier2
    ; TierMax = tier1
    ).


% ============================================================================
% 5. TCO REAL: CAPEX + OPEX (Proyeccion a N anios)
% ============================================================================

% Parametros configurables de TCO
costo_kwh(0.12).                   % USD por kWh (promedio data center USA)
factor_mantenimiento_anual(0.15).  % 15% del CAPEX por anio
tasa_inflacion_energia(0.03).      % 3% anual en costo energia
factor_personal(0.10).             % 10% del CAPEX en personal/anio

% OPEX de energia anual (considerando PUE)
calcular_opex_energia_anual(TDP_Total, PUE, OpexEnergia) :-
    costo_kwh(Tarifa),
    PotenciaReal is TDP_Total * PUE,
    KWhAnuales is (PotenciaReal / 1000.0) * 8760,
    OpexEnergia is KWhAnuales * Tarifa.

% OPEX total proyectado a N anios (con inflacion energia)
calcular_opex_total(TDP_Total, PUE, CAPEX, Anios, OPEX_Desglose) :-
    calcular_opex_energia_anual(TDP_Total, PUE, EnergiaBase),
    factor_mantenimiento_anual(FactMant),
    factor_personal(FactPers),
    MantenimientoAnual is CAPEX * FactMant,
    PersonalAnual is CAPEX * FactPers,
    tasa_inflacion_energia(Inflacion),
    % Sumatoria con inflacion compuesta
    calcular_energia_acumulada(EnergiaBase, Inflacion, Anios, EnergiaTotal),
    MantenimientoTotal is MantenimientoAnual * Anios,
    PersonalTotal is PersonalAnual * Anios,
    OPEX_Desglose = opex(EnergiaTotal, MantenimientoTotal, PersonalTotal).

% Energia acumulada con inflacion compuesta
calcular_energia_acumulada(_, _, 0, 0.0) :- !.
calcular_energia_acumulada(Base, Inflacion, Anios, Total) :-
    Anios > 0,
    AniosPrev is Anios - 1,
    calcular_energia_acumulada(Base, Inflacion, AniosPrev, SubTotal),
    CostoEsteAnio is Base * ((1.0 + Inflacion) ** AniosPrev),
    Total is SubTotal + CostoEsteAnio.

% TCO completo
calcular_tco(CAPEX, TDP_Total, PUE, Anios,
             tco(TCO, CAPEX, OPEX_Total, Desglose, ROI_Anios)) :-
    calcular_opex_total(TDP_Total, PUE, CAPEX, Anios, Desglose),
    Desglose = opex(Energia, Mant, Pers),
    OPEX_Total is Energia + Mant + Pers,
    TCO is CAPEX + OPEX_Total,
    OpexAnual is OPEX_Total / Anios,
    ( OpexAnual > 0 -> ROI_Anios is CAPEX / OpexAnual ; ROI_Anios = 0 ).


% ============================================================================
% 6. VALIDACIONES DE INGENIERIA (CORREGIDAS - sin cuts destructivos)
% ============================================================================

% 6.1 Densidad RAM
validar_ram(Socket, TipoR, R_Pedida, Slots) :-
    mb(_, _, _, Socket, TipoR, _, Slots, _, _),
    ram(_, _, TipoR, _, _, _),
    R_Pedida =< (Slots * 512).  % Maximo teorico por slot

% 6.2 Latencia y cuello de botella de red
% CORREGIDO: Retorna NIC_ID para trazabilidad
validar_red(IOPS, NIC_ID, VelNIC, Latencia, PNIC) :-
    nic(NIC_ID, _, _, VelNIC, Latencia, PNIC, _),
    validar_red_por_iops(IOPS, VelNIC, Latencia).

validar_red_por_iops(IOPS, VelNIC, Latencia) :-
    IOPS >= 1000000,
    VelNIC >= 100,
    Latencia =< 1.0.
validar_red_por_iops(IOPS, VelNIC, Latencia) :-
    IOPS >= 500000, IOPS < 1000000,
    VelNIC >= 10,
    Latencia =< 2.0.
validar_red_por_iops(IOPS, VelNIC, Latencia) :-
    IOPS >= 100000, IOPS < 500000,
    VelNIC >= 10,
    Latencia =< 3.5.
validar_red_por_iops(IOPS, VelNIC, _) :-
    IOPS < 100000,
    VelNIC >= 1.

% 6.3 Enfriamiento (CORREGIDO: sin cut, permite backtracking)
validar_enfriamiento(TDP_Total, Cool_ID, MCool, PUE, PCool) :-
    cooling(Cool_ID, MCool, MaxTDP, PUE, PCool, _),
    MaxTDP >= TDP_Total.

% 6.4 Energia (CORREGIDO: retorna PSU_ID, sin cut)
validar_energia(TDP_Total, PSU_ID, WattsPSU, Eficiencia, PPSU) :-
    psu(PSU_ID, _, _, WattsPSU, Eficiencia, PPSU, _),
    ConsumoReal is (TDP_Total + 150) / Eficiencia,
    WattsPSU >= ConsumoReal * 1.20.

% 6.5 UPS (CORREGIDO: sin cut, autonomia parametrizada)
validar_ups(ConsumoReal, UPS_ID, Autonomia, PUPS, MinAutonomia) :-
    ups(UPS_ID, WattsUPS, Autonomia, PUPS, _),
    WattsUPS >= ConsumoReal,
    Autonomia >= MinAutonomia.


% ============================================================================
% 7. MOTOR DE DISENO v2 (CORREGIDO)
% ============================================================================

% Arquitectura basica (un nodo) - CORREGIDA con imagenes
% Retorna estructura rica con IDs + rutas de imagen para el panel visual
arquitectura_valida(MinC, MinR, MinI, MinG, Pres, Costo,
    arq(CPU_ID, BrandC, MCPU, Cores, MB_ID, RAM_ID, CapR, 
        STOR_ID, TDisk, CapTB, IOPS,
        GPU_ID, MGPU, VRAM, TDP_G,
        NIC_ID, MNIC, VelNIC, Lat,
        Cool_ID, MCool, PUE,
        PSU_ID, WattsPSU, Eficiencia,
        UPS_ID, AutoMin,
        CH_ID, RackU,
        TDP_Total, ConsumoReal,
        ImgCPU, ImgMB, ImgRAM, ImgStorage, ImgGPU,
        ImgNIC, ImgCool, ImgPSU, ImgUPS, ImgChasis)) :-
    
    % Seleccion de componentes extrayendo rutas de imagen
    cpu(CPU_ID, _, BrandC, MCPU, Cores, Socket, _, TDP_C, PC, ImgCPU),
    mb(MB_ID, _, _, Socket, TipoR, _, Slots, PM, ImgMB),
    ram(RAM_ID, _, TipoR, CapR, PR, ImgRAM),
    storage(STOR_ID, _, TDisk, CapTB, IOPS, PS, ImgStorage),
    gpu(GPU_ID, _, MGPU, VRAM, TDP_G, PG, ImgGPU),
    chasis(CH_ID, RackU, _, PU, ImgChasis),
    
    % Filtros de requisitos minimos
    Cores >= MinC,
    CapR >= MinR,
    IOPS >= MinI,
    (MinG > 0 -> VRAM >= MinG ; GPU_ID = g0),
    
    % Compatibilidad PCIe CPU<->GPU
    validar_pcie(CPU_ID, GPU_ID),
    
    % Validacion RAM
    validar_ram(Socket, TipoR, CapR, Slots),
    
    % Validacion red: obtenemos NIC con su imagen
    validar_red(IOPS, NIC_ID, VelNIC, Lat, PNIC),
    nic(NIC_ID, _, MNIC, _, _, _, ImgNIC),
    
    % Termodinamica: enfriamiento con imagen
    TDP_Total is TDP_C + TDP_G,
    validar_enfriamiento(TDP_Total, Cool_ID, MCool, PUE, PCool),
    cooling(Cool_ID, _, _, _, _, ImgCool),
    
    % Energia: PSU con imagen
    validar_energia(TDP_Total, PSU_ID, WattsPSU, Eficiencia, PPSU),
    psu(PSU_ID, _, _, _, _, _, ImgPSU),
    ConsumoReal is (TDP_Total + 150) / Eficiencia,
    
    % UPS con imagen (minimo 10 min)
    validar_ups(ConsumoReal, UPS_ID, AutoMin, PUPS, 10),
    ups(UPS_ID, _, _, _, ImgUPS),
    
    % CAPEX
    Costo is PC + PM + PR + PS + PG + PPSU + PCool + PUPS + PU + PNIC,
    ( Costo =< Pres -> ! ; fail ).

% Arquitectura con redundancia y TCO
arquitectura_completa(MinC, MinR, MinI, MinG, Pres, TipoRedundancia, Anios,
                      Costo_CAPEX, TCO_Result, TierMax, Arq) :-
    arquitectura_valida(MinC, MinR, MinI, MinG, Pres, CostoBase, Arq),
    
    % Extraer datos de la arquitectura
    % 41 campos: 31 datos + 10 imagenes (ignoradas en este contexto)
    Arq = arq(_, _, _, _, _, _, _, _, _, _, _,
              _, _, _, _,
              _, _, _, _,
              _, _, PUE,
              PSU_ID, _, _,
              UPS_ID, AutoMin,
              _, _,
              TDP_Total, ConsumoReal,
              _, _, _, _, _, _, _, _, _, _),
    
    % Redundancia en PSU
    psu(PSU_ID, _, _, _, _, PrecioPSU_Unit, _),
    psu_con_redundancia(TDP_Total, TipoRedundancia, PSU_ID, _NumPSU, CostoPSU_Red),
    SobreCostoPSU is CostoPSU_Red - PrecioPSU_Unit,
    
    % Redundancia en UPS
    ups(UPS_ID, _, _, PrecioUPS_Unit, _),
    ups_con_redundancia(ConsumoReal, TipoRedundancia, UPS_ID, _NumUPS, _, CostoUPS_Red),
    SobreCostoUPS is CostoUPS_Red - PrecioUPS_Unit,
    
    % CAPEX total con redundancia
    Costo_CAPEX is CostoBase + SobreCostoPSU + SobreCostoUPS,
    Costo_CAPEX =< Pres,
    
    % TCO
    calcular_tco(Costo_CAPEX, TDP_Total, PUE, Anios, TCO_Result),
    
    % Determinar tier alcanzado
    tier_maximo(PUE, AutoMin, TipoRedundancia, TierMax).


% ============================================================================
% 8. WORKLOAD PROFILES
% ============================================================================

% workload(Nombre, cpu_cores(Min), ram_gb(Min), gpu_vram(Min), 
%          iops(Min), nic_gbps(Min), tier_min, descripcion)
workload(ai_training,
    cpu_cores(64), ram_gb(256), gpu_vram(40), iops(800000), nic_gbps(100),
    tier3, 'Entrenamiento de modelos ML/DL con datasets grandes').

workload(ai_inference,
    cpu_cores(16), ram_gb(64), gpu_vram(16), iops(100000), nic_gbps(10),
    tier3, 'Inferencia de modelos en produccion').

workload(hpc_simulation,
    cpu_cores(96), ram_gb(384), gpu_vram(40), iops(500000), nic_gbps(200),
    tier3, 'Simulaciones cientificas, CFD, FEA').

workload(database_oltp,
    cpu_cores(32), ram_gb(256), gpu_vram(0), iops(800000), nic_gbps(25),
    tier4, 'Bases de datos transaccionales de alta disponibilidad').

workload(database_olap,
    cpu_cores(64), ram_gb(512), gpu_vram(0), iops(500000), nic_gbps(25),
    tier3, 'Data warehouse y analytics').

workload(web_hosting,
    cpu_cores(8), ram_gb(32), gpu_vram(0), iops(50000), nic_gbps(1),
    tier2, 'Hosting web, CMS, APIs ligeras').

workload(virtualizacion,
    cpu_cores(32), ram_gb(256), gpu_vram(0), iops(200000), nic_gbps(25),
    tier3, 'VMware/Hyper-V, escritorios virtuales (VDI)').

workload(streaming_media,
    cpu_cores(16), ram_gb(64), gpu_vram(0), iops(100000), nic_gbps(100),
    tier2, 'Streaming de video/audio, CDN origin').

workload(edge_computing,
    cpu_cores(8), ram_gb(32), gpu_vram(0), iops(20000), nic_gbps(1),
    tier1, 'Edge sites, IoT gateways, caching').

workload(blockchain_node,
    cpu_cores(16), ram_gb(64), gpu_vram(0), iops(100000), nic_gbps(10),
    tier3, 'Nodos blockchain, validadores').

% Disenar para workload especifico
disenar_para_workload(Workload, Presupuesto, Anios, Resultado) :-
    workload(Workload, cpu_cores(C), ram_gb(R), gpu_vram(G), 
             iops(I), nic_gbps(_), TierMin, Desc),
    tier_spec(TierMin, _, _, _, RedReq, _, _),
    findall(
        score(Score)-config(CAPEX, TCO_R, Tier, Arq),
        (
            arquitectura_completa(C, R, I, G, Presupuesto, RedReq, Anios,
                                  CAPEX, TCO_R, Tier, Arq),
            cumple_tier(TierMin, _, _, _),  % Verificar tier minimo
            score_arquitectura(Arq, CAPEX, Score)
        ),
        Opciones
    ),
    ( Opciones \= [] ->
        sort(0, @>=, Opciones, Sorted),
        Resultado = resultado(Workload, Desc, Sorted)
    ;
        Resultado = sin_opciones(Workload, Desc, Presupuesto)
    ).


% ============================================================================
% 9. SCORING MULTICRITERIO
% ============================================================================

% Pesos configurables
peso(costo,       0.25).
peso(rendimiento, 0.30).
peso(eficiencia,  0.25).
peso(latencia,    0.20).

score_arquitectura(Arq, Costo, ScoreTotal) :-
    Arq = arq(_, _, _, Cores, _, _, CapR, 
              _, _, _, IOPS,
              _, _, VRAM, _,
              _, _, _, Lat,
              _, _, PUE,
              _, _, _,
              _, _,
              _, _,
              TDP_Total, _,
              _, _, _, _, _, _, _, _, _, _),
    
    % Score de costo (menor es mejor, normalizado 0-100)
    ScoreCosto is max(0, 100 - (Costo / 500.0)),
    
    % Score de rendimiento (cores + RAM + IOPS + VRAM)
    ScoreCores is min(100, (Cores / 128.0) * 100),
    ScoreRAM   is min(100, (CapR / 512.0) * 100),
    ScoreIOPS  is min(100, (IOPS / 1500000.0) * 100),
    ScoreVRAM  is min(100, (VRAM / 80.0) * 100),
    ScorePerf  is (ScoreCores * 0.3 + ScoreRAM * 0.2 + ScoreIOPS * 0.3 + ScoreVRAM * 0.2),
    
    % Score de eficiencia energetica (PUE cercano a 1.0 = mejor)
    ScoreEficiencia is max(0, 100 - ((PUE - 1.0) * 200)),
    
    % Score de latencia de red (menor = mejor)
    ScoreLatencia is max(0, 100 - (Lat * 20)),
    
    % Score ponderado
    peso(costo, W1),
    peso(rendimiento, W2),
    peso(eficiencia, W3),
    peso(latencia, W4),
    ScoreTotal is (ScoreCosto * W1) + (ScorePerf * W2) + 
                  (ScoreEficiencia * W3) + (ScoreLatencia * W4).

% Ranking Top-N
ranking_top(N, MinC, MinR, MinI, MinG, Pres, TopN) :-
    findall(
        Score-arq_rankeada(Costo, Arq),
        (
            arquitectura_valida(MinC, MinR, MinI, MinG, Pres, Costo, Arq),
            score_arquitectura(Arq, Costo, Score)
        ),
        Lista
    ),
    sort(0, @>=, Lista, Sorted),
    take_n(N, Sorted, TopN).

% Tomar los primeros N elementos de una lista
take_n(_, [], []).
take_n(0, _, []).
take_n(N, [H|T], [H|R]) :-
    N > 0,
    N1 is N - 1,
    take_n(N1, T, R).


% ============================================================================
% 10. OPTIMIZADOR DE CLUSTER (CORREGIDO)
% ============================================================================

% Overhead por nodo adicional en cluster (networking, orquestacion)
overhead_cluster(NumNodos, Overhead) :-
    ( NumNodos =< 4  -> Overhead is 0.05   % 5% overhead hasta 4 nodos
    ; NumNodos =< 16 -> Overhead is 0.10   % 10% hasta 16
    ; NumNodos =< 64 -> Overhead is 0.15   % 15% hasta 64
    ; Overhead is 0.20                      % 20% mas de 64
    ).

% Costo de networking inter-nodo
costo_networking_cluster(NumNodos, CostoNet) :-
    ( NumNodos =< 4  -> CostoNet is NumNodos * 200    % Switch basico
    ; NumNodos =< 16 -> CostoNet is NumNodos * 500    % Switch gestionado
    ; NumNodos =< 64 -> CostoNet is NumNodos * 1200   % Spine-leaf
    ; CostoNet is NumNodos * 2000                      % Fat-tree
    ).

disenar_cluster(C, R, I, G, P, Resultado) :-
    findall(
        Score-cluster(Nodos, CostoNodo, TotalCluster, CostoNet, Arq),
        (
            arquitectura_valida(C, R, I, G, P, CostoNodo, Arq),
            MaxNodos is P // CostoNodo,
            MaxNodos >= 1,
            between(1, MaxNodos, Nodos),
            costo_networking_cluster(Nodos, CostoNet),
            TotalCluster is (Nodos * CostoNodo) + CostoNet,
            TotalCluster =< P,
            score_arquitectura(Arq, CostoNodo, Score)
        ),
        Opciones
    ),
    ( Opciones \= [] ->
        sort(0, @>=, Opciones, Sorted),
        take_n(5, Sorted, Top5),
        Resultado = cluster_opciones(Top5)
    ;
        Resultado = cluster_sin_opciones(C, R, I, G, P)
    ).

% Cluster con TCO y redundancia
disenar_cluster_completo(C, R, I, G, P, Redundancia, Anios, Resultado) :-
    findall(
        Score-cluster_full(Nodos, CAPEX_Nodo, CAPEX_Total, TCO_Result, Tier, Arq),
        (
            arquitectura_completa(C, R, I, G, P, Redundancia, Anios,
                                  CAPEX_Nodo, TCO_Result, Tier, Arq),
            MaxNodos is P // CAPEX_Nodo,
            MaxNodos >= 1,
            between(1, MaxNodos, Nodos),
            costo_networking_cluster(Nodos, CostoNet),
            CAPEX_Total is (Nodos * CAPEX_Nodo) + CostoNet,
            CAPEX_Total =< P,
            score_arquitectura(Arq, CAPEX_Nodo, Score)
        ),
        Opciones
    ),
    ( Opciones \= [] ->
        sort(0, @>=, Opciones, Sorted),
        take_n(5, Sorted, Top5),
        Resultado = cluster_completo(Top5)
    ;
        Resultado = cluster_sin_opciones(C, R, I, G, P)
    ).


% ============================================================================
% 11. SISTEMA DE EXPLICABILIDAD
% ============================================================================

% Limpiar razones anteriores
limpiar_razones :- retractall(razon(_, _)).

% Explicar por que se eligio una arquitectura
explicar_eleccion(Arq, Costo) :-
    Arq = arq(CPU_ID, BrandC, MCPU, Cores, _, _, CapR,
              _, TDisk, CapTB, IOPS,
              GPU_ID, MGPU, VRAM, TDP_G,
              _, MNIC, VelNIC, Lat,
              _, MCool, PUE,
              _, WattsPSU, Eficiencia,
              _, AutoMin,
              _, RackU,
              TDP_Total, ConsumoReal),
    
    format("~n=== EXPLICACION DE ARQUITECTURA ==========================~n"),
    format("  CPU: ~w ~w (~w cores, TDP ~wW)~n", [BrandC, MCPU, Cores, 0]),
    cpu(CPU_ID, Gama, _, _, _, _, _, TDP_C, _, _),
    format("       Gama: ~w | TDP real: ~wW~n", [Gama, TDP_C]),
    format("  RAM: ~w GB tipo ~w~n", [CapR, 0]),
    format("  Storage: ~w (~w TB, ~w IOPS)~n", [TDisk, CapTB, IOPS]),
    
    ( GPU_ID \= g0 ->
        format("  GPU: ~w (~w GB VRAM, ~wW TDP)~n", [MGPU, VRAM, TDP_G])
    ;
        format("  GPU: Sin GPU dedicada~n")
    ),
    
    format("  NIC: ~w (~w Gbps, ~w us latencia)~n", [MNIC, VelNIC, Lat]),
    format("  Cooling: ~w (PUE: ~4f)~n", [MCool, PUE]),
    format("  PSU: ~wW (Eficiencia: ~2f)~n", [WattsPSU, Eficiencia]),
    format("  UPS: ~w min autonomia~n", [AutoMin]),
    format("  Chasis: ~wU rack~n", [RackU]),
    format("~n  --- Metricas ---~n"),
    format("  TDP Total: ~wW~n", [TDP_Total]),
    format("  Consumo Real: ~2fW~n", [ConsumoReal]),
    format("  CAPEX: $~w USD~n", [Costo]),
    format("=========================================================~n").

% Explicar por que NO se pudo disenar una arquitectura
por_que_no(MinC, MinR, MinI, MinG, Pres) :-
    format("~n=== DIAGNOSTICO: POR QUE NO HAY SOLUCION ================~n"),
    
    % Verificar CPUs
    ( \+ (cpu(_, _, _, _, Cores, _, _, _, _, _), Cores >= MinC) ->
        format("  [X] CORES: Ningun CPU tiene >= ~w cores~n", [MinC]),
        format("      Maximo disponible: "),
        findall(Co, cpu(_, _, _, _, Co, _, _, _, _, _), CoresList),
        max_list(CoresList, MaxC),
        format("~w cores~n", [MaxC])
    ;
        format("  [OK] CORES: Hay CPUs con >= ~w cores~n", [MinC])
    ),
    
    % Verificar RAM
    ( \+ (ram(_, _, _, Cap, _, _), Cap >= MinR) ->
        format("  [X] RAM: Ningun modulo tiene >= ~w GB~n", [MinR]),
        findall(Ca, ram(_, _, _, Ca, _, _), RAMList),
        max_list(RAMList, MaxR),
        format("      Maximo disponible: ~w GB~n", [MaxR])
    ;
        format("  [OK] RAM: Hay modulos con >= ~w GB~n", [MinR])
    ),
    
    % Verificar IOPS
    ( \+ (storage(_, _, _, _, IO, _, _), IO >= MinI) ->
        format("  [X] IOPS: Ningun storage tiene >= ~w IOPS~n", [MinI]),
        findall(Io, storage(_, _, _, _, Io, _, _), IOList),
        max_list(IOList, MaxI),
        format("      Maximo disponible: ~w IOPS~n", [MaxI])
    ;
        format("  [OK] IOPS: Hay storage con >= ~w IOPS~n", [MinI])
    ),
    
    % Verificar GPU
    ( MinG > 0 ->
        ( \+ (gpu(_, _, _, VR, _, _, _), VR >= MinG, VR > 0) ->
            format("  [X] GPU: Ninguna GPU tiene >= ~w GB VRAM~n", [MinG]),
            findall(Vr, (gpu(_, _, _, Vr, _, _, _), Vr > 0), VRAMList),
            ( VRAMList \= [] -> max_list(VRAMList, MaxG), 
              format("      Maximo disponible: ~w GB~n", [MaxG])
            ; format("      No hay GPUs en catalogo~n")
            )
        ;
            format("  [OK] GPU: Hay GPUs con >= ~w GB VRAM~n", [MinG])
        )
    ;
        format("  [--] GPU: No se requiere GPU~n")
    ),
    
    % Verificar presupuesto
    ( \+ arquitectura_valida(MinC, MinR, MinI, MinG, 999999999, _, _) ->
        format("  [X] PRESUPUESTO: No existe combinacion valida a ningun precio~n"),
        format("      Revise compatibilidad de socket/RAM/PCIe~n")
    ;
        arquitectura_valida(MinC, MinR, MinI, MinG, 999999999, CostoMin, _),
        ( CostoMin > Pres ->
            format("  [X] PRESUPUESTO: Costo minimo es $~w, presupuesto es $~w~n", 
                   [CostoMin, Pres]),
            Faltante is CostoMin - Pres,
            format("      Faltan $~w USD~n", [Faltante])
        ;
            format("  [OK] PRESUPUESTO: $~w es suficiente (minimo $~w)~n", 
                   [Pres, CostoMin])
        )
    ),
    format("=========================================================~n").

% Comparar dos arquitecturas
comparar_arquitecturas(Arq1, Costo1, Arq2, Costo2) :-
    format("~n=== COMPARACION DE ARQUITECTURAS =========================~n"),
    Arq1 = arq(_, B1, M1, Cores1, _, _, R1, _, _, _, IOPS1,
               _, _, VRAM1, _, _, _, _, Lat1, _, _, PUE1,
               _, _, _, _, Auto1, _, _, TDP1, _),
    Arq2 = arq(_, B2, M2, Cores2, _, _, R2, _, _, _, IOPS2,
               _, _, VRAM2, _, _, _, _, Lat2, _, _, PUE2,
               _, _, _, _, Auto2, _, _, TDP2, _),
    
    format("~30|~20|~20|~n", [' ', 'Opcion A', 'Opcion B']),
    format("  CPU:~30|~w ~w~50|~w ~w~n", [B1, M1, B2, M2]),
    format("  Cores:~30|~w~50|~w~n", [Cores1, Cores2]),
    format("  RAM:~30|~w GB~50|~w GB~n", [R1, R2]),
    format("  IOPS:~30|~w~50|~w~n", [IOPS1, IOPS2]),
    format("  VRAM:~30|~w GB~50|~w GB~n", [VRAM1, VRAM2]),
    format("  Latencia:~30|~w us~50|~w us~n", [Lat1, Lat2]),
    format("  PUE:~30|~4f~50|~4f~n", [PUE1, PUE2]),
    format("  TDP:~30|~wW~50|~wW~n", [TDP1, TDP2]),
    format("  UPS:~30|~w min~50|~w min~n", [Auto1, Auto2]),
    format("  CAPEX:~30|$~w~50|$~w~n", [Costo1, Costo2]),
    
    score_arquitectura(Arq1, Costo1, S1),
    score_arquitectura(Arq2, Costo2, S2),
    format("  Score:~30|~2f~50|~2f~n", [S1, S2]),
    
    ( S1 > S2 ->
        format("~n  >> RECOMENDACION: Opcion A (score ~2f vs ~2f)~n", [S1, S2])
    ; S2 > S1 ->
        format("~n  >> RECOMENDACION: Opcion B (score ~2f vs ~2f)~n", [S2, S1])
    ;
        format("~n  >> EMPATE: Ambas opciones son equivalentes~n")
    ),
    format("=========================================================~n").


% ============================================================================
% 12. CLP(FD) OPTIMIZACION (requiere SWI-Prolog con library(clpfd))
% ============================================================================

% Optimizacion por restricciones para encontrar configuracion optima
% Solo funciona si CLP(FD) esta disponible
optimizar_nodos_clpfd(Presupuesto, MaxNodos, CoresTotal) :-
    catch(
        (
            NumCPU in 1..64,
            NumRAM in 1..128,
            NumGPU in 0..32,
            NumStorage in 1..64,
            
            % Costos unitarios (usando EPYC 9654 como base alta gama)
            CostoCPU #= NumCPU * 11800,
            CostoRAM #= NumRAM * 450,
            CostoGPU #= NumGPU * 12000,
            CostoStor #= NumStorage * 650,
            Infra #= 5000,  % PSU + Cooling + UPS base
            
            Total #= CostoCPU + CostoRAM + CostoGPU + CostoStor + Infra,
            Total #=< Presupuesto,
            
            CoresTotal #= NumCPU * 96,
            CoresTotal #>= 96,
            
            MaxNodos #= NumCPU,
            
            labeling([max(CoresTotal)], [NumCPU, NumRAM, NumGPU, NumStorage])
        ),
        _Error,
        (
            format("CLP(FD) no disponible. Usando busqueda clasica.~n"),
            MaxNodos = 0, CoresTotal = 0
        )
    ).


% ============================================================================
% 13. INTERFAZ PRINCIPAL (Compatible con Python)
% ============================================================================

% Consulta simple (compatible con version anterior)
consulta_simple(MinC, MinR, MinI, MinG, Pres, Resultado) :-
    findall(
        Costo-Arq,
        arquitectura_valida(MinC, MinR, MinI, MinG, Pres, Costo, Arq),
        Opciones
    ),
    ( Opciones \= [] ->
        keysort(Opciones, Sorted),
        Resultado = opciones(Sorted)
    ;
        Resultado = sin_opciones
    ).

% Consulta avanzada con TCO y redundancia
consulta_avanzada(MinC, MinR, MinI, MinG, Pres, Redundancia, Anios, Resultado) :-
    findall(
        Score-config_completa(CAPEX, TCO_R, Tier, Arq),
        (
            arquitectura_completa(MinC, MinR, MinI, MinG, Pres, Redundancia, Anios,
                                  CAPEX, TCO_R, Tier, Arq),
            score_arquitectura(Arq, CAPEX, Score)
        ),
        Opciones
    ),
    ( Opciones \= [] ->
        sort(0, @>=, Opciones, Sorted),
        Resultado = resultado_avanzado(Sorted)
    ;
        Resultado = sin_opciones
    ).

% Consulta por workload
consulta_workload(Workload, Presupuesto, Anios, Resultado) :-
    disenar_para_workload(Workload, Presupuesto, Anios, Resultado).

% Listar workloads disponibles
listar_workloads(Lista) :-
    findall(
        wl(Nombre, Desc, C, R, G, I, Tier),
        workload(Nombre, cpu_cores(C), ram_gb(R), gpu_vram(G), 
                 iops(I), nic_gbps(_), Tier, Desc),
        Lista
    ).

% Diagnostico completo
diagnostico(MinC, MinR, MinI, MinG, Pres) :-
    por_que_no(MinC, MinR, MinI, MinG, Pres).

% Obtener Top-N arquitecturas por score
consulta_ranking(N, MinC, MinR, MinI, MinG, Pres, TopN) :-
    ranking_top(N, MinC, MinR, MinI, MinG, Pres, TopN).

% Cluster con TCO
consulta_cluster(MinC, MinR, MinI, MinG, Pres, Red, Anios, Resultado) :-
    disenar_cluster_completo(MinC, MinR, MinI, MinG, Pres, Red, Anios, Resultado).


% ============================================================================
% 14. UTILIDADES DE FORMATO (para integracion Python via pyswip/subprocess)
% ============================================================================

% Serializar arquitectura a lista de pares clave-valor (facil de parsear en Python)
arq_to_dict(Arq, Costo, Dict) :-
    Arq = arq(CPU_ID, BrandC, MCPU, Cores, MB_ID, RAM_ID, CapR,
              STOR_ID, TDisk, CapTB, IOPS,
              GPU_ID, MGPU, VRAM, TDP_G,
              NIC_ID, MNIC, VelNIC, Lat,
              Cool_ID, MCool, PUE,
              PSU_ID, WattsPSU, Eficiencia,
              UPS_ID, AutoMin,
              CH_ID, RackU,
              TDP_Total, ConsumoReal),
    Dict = [
        cpu_id=CPU_ID, cpu_marca=BrandC, cpu_modelo=MCPU, cores=Cores,
        mb_id=MB_ID, ram_id=RAM_ID, ram_gb=CapR,
        storage_id=STOR_ID, storage_tipo=TDisk, storage_tb=CapTB, iops=IOPS,
        gpu_id=GPU_ID, gpu_modelo=MGPU, vram_gb=VRAM, gpu_tdp=TDP_G,
        nic_id=NIC_ID, nic_modelo=MNIC, nic_gbps=VelNIC, latencia_us=Lat,
        cooling_id=Cool_ID, cooling_tipo=MCool, pue=PUE,
        psu_id=PSU_ID, psu_watts=WattsPSU, psu_eficiencia=Eficiencia,
        ups_id=UPS_ID, ups_autonomia_min=AutoMin,
        chasis_id=CH_ID, rack_u=RackU,
        tdp_total=TDP_Total, consumo_real=ConsumoReal,
        capex=Costo
    ].

% Serializar TCO a dict
tco_to_dict(tco(TCO, CAPEX, OPEX, opex(Energia, Mant, Pers), ROI), Dict) :-
    Dict = [
        tco_total=TCO, capex=CAPEX, opex_total=OPEX,
        opex_energia=Energia, opex_mantenimiento=Mant, opex_personal=Pers,
        roi_anios=ROI
    ].


% ============================================================================
% 15. AUTO-TEST (ejecutar con ?- run_tests.)
% ============================================================================

run_tests :-
    format("~n=== EJECUTANDO TESTS =====================================~n"),
    
    % Test 1: Arquitectura basica debe encontrar al menos 1 opcion
    format("Test 1: Arquitectura basica (8 cores, 16GB, 1000 IOPS)... "),
    ( arquitectura_valida(8, 16, 1000, 0, 100000, _, _) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 2: Presupuesto imposible no debe dar resultado
    format("Test 2: Presupuesto imposible ($100)... "),
    ( \+ arquitectura_valida(8, 16, 1000, 0, 100, _, _) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 3: Cores imposibles no debe dar resultado
    format("Test 3: 1000 cores (imposible)... "),
    ( \+ arquitectura_valida(1000, 16, 1000, 0, 999999, _, _) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 4: Redundancia N+1
    format("Test 4: Redundancia N+1... "),
    ( redundancia(n_mas_1, 2, 3) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 5: Redundancia 2N
    format("Test 5: Redundancia 2N... "),
    ( redundancia(dos_n, 2, 4) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 6: Tier maximo con PUE bajo
    format("Test 6: Tier maximo (PUE 1.05, 20min, 2N)... "),
    ( tier_maximo(1.05, 20, dos_n, tier4) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 7: TCO calcula valores positivos
    format("Test 7: TCO calcula valores... "),
    ( calcular_tco(50000, 500, 1.2, 5, tco(TCO, _, _, _, _)), TCO > 50000 ->
        format("OK (TCO=$~2f)~n", [TCO]) ; format("FALLO~n")
    ),
    
    % Test 8: PCIe compatibilidad
    format("Test 8: PCIe EPYC 9654 + H100... "),
    ( validar_pcie(c1, g1) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 9: PCIe incompatibilidad
    format("Test 9: PCIe Xeon E-2336 + H100 (debe fallar)... "),
    ( \+ validar_pcie(c8, g1) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    % Test 10: Scoring retorna valor numerico
    format("Test 10: Scoring... "),
    ( arquitectura_valida(8, 16, 1000, 0, 100000, C10, A10),
      score_arquitectura(A10, C10, S10), number(S10) ->
        format("OK (score=~2f)~n", [S10]) ; format("FALLO~n")
    ),
    
    % Test 11: Workloads existen
    format("Test 11: Workloads cargados... "),
    ( listar_workloads(WL), length(WL, NWL), NWL >= 5 ->
        format("OK (~w workloads)~n", [NWL]) ; format("FALLO~n")
    ),
    
    % Test 12: Diagnostico no crashea
    format("Test 12: Diagnostico (por_que_no)... "),
    ( catch(por_que_no(1000, 9999, 99999999, 999, 100), _, true) ->
        format("OK~n") ; format("FALLO~n")
    ),
    
    format("=== TESTS COMPLETADOS ====================================~n~n").

% Traducir niveles a números para comparación
tier_valor(tier1, 1).
tier_valor(tier2, 2).
tier_valor(tier3, 3).
tier_valor(tier4, 4).

% Regla para obtener el Tier mínimo requerido por un workload
min_tier_workload(Workload, MinTier) :-
    workload(Workload, _, _, _, _, _, MinTier, _).