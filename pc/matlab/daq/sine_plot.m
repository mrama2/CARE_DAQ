t = 0 ;
x = 0 ;
T = 0;
interv = 1000 ; % considering 1000 samples
Sampling_Frequncy = 100; 
Total_Num_Points = 5000;
step = (1./Sampling_Frequncy) ; % lowering step has a number of cycles and then acquire more data
while ( t <interv )
    b = sin(6.28*t)+5;
    x = [ x, b ];
    T = [T,t/step];
    plot(T, x) ;
    sx =size(x);
      if (sx(2)-Total_Num_Points > 0)
          x = x(2:end);
          T = T(2:end);
      end
      axis([ T(1), T(1)+Total_Num_Points, 0 , 10 ]);
      grid
      t = t + step;
      drawnow;
      %pause(step)
 end