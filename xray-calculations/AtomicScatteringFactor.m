function [f] = AtomicScatteringFactor(matname, d_hkls)

switch matname
    case 'C'
        a1  = 2.310000;
        b1  = 20.843900;
        a2  = 1.020000;
        b2  = 10.207500;
        a3  = 1.588600;
        b3  = 0.568700;
        a4  = 0.865000;
        b4  = 51.651200;
        c   = 0.215600;
    case 'Al'
        a1  = 6.420200;
        b1  = 3.038700;
        a2  = 1.900200;
        b2  = 0.742600;
        a3  = 1.593600;
        b3  = 31.547200;
        a4  = 1.964600;
        b4  = 85.088600;
        c   = 1.115100;
    case 'Ti'
        a1  = 9.759500;
        b1  = 7.850800;
        a2  = 7.355800;
        b2  = 0.500000;
        a3  = 1.699100;
        b3  = 35.633800;
        a4  = 1.902100;
        b4  = 116.105000;
        c   = 1.280700;
    case 'Fe'
        a1  = 11.769500;
        b1  = 4.76110;
        a2  = 7.357300;
        b2  = 0.307200;
        a3  = 3.522200;
        b3  = 15.353500;
        a4  = 2.304500;
        b4  = 76.880500;
        c   = 1.011800;
    case 'Ni'
        a1  = 12.837600;
        b1  = 3.878500;
        a2  = 7.292000;
        b2  = 0.256500;
        a3  = 4.443800;
        b3  = 12.176300;
        a4  = 2.38000;
        b4  = 66.342100;
        c   = 1.034100;
    case 'Cu'
        a1  = 13.338000;
        b1  = 3.582800;
        a2  = 7.167600;
        b2  = 0.247000;
        a3  = 5.615800;
        b3  = 11.396600;
        a4  = 1.673500;
        b4  = 64.812600;
        c   = 1.191000;
    otherwise
        disp('material not defined')
end

a   = [a1 a2 a3 a4];
b   = [b1 b2 b3 b4];

x   = 0.5./d_hkls;
f   = c;
for i = 1:1:4
    f   = f + a(i)*exp(-b(i)*x.*x);
end