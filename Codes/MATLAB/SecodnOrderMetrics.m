clear; clc ;
% sys=tf([3],[1 2 6]);
% step(sys);

G=tf(1,[1 0.6 4])
sys=feedback(G,1);
tt=8;h=0.01;  %tt代表时间范围,h代表步长
t=0:h:tt;     %定义时间范围
step(sys,t);
y=step(sys,t);
[PeakValue,PeakTime]=max(step(sys,t));  %求最大值,即超调量
PeakTime=PeakTime*h;                %最大值的位置
ys=mean(y(length(t)-10:length(t))); %求最终响应值,最后10个数平均
sigma = (PeakValue-ys)/ys;              %超调量百分比
ess = 1 - ys;
for k=1:length(t)   %寻找到第一次y(k)>0.1ys即停止
    if y(k) >= ys * 0.1
        T0=k;break;
    end
end
for k=1:length(t)   %寻找到第一次y(k)>0.9ys即停止
    if y(k) >= ys * 0.9
        T1=k;break;
    end
end
RiseTime=(T1-T0)*h;  %求上升时间

ppm=0.05;            %容许范围+-5%
yup=ys*(1+ppm);
ydown=ys*(1-ppm);

if PeakValue <= yup   %如果峰值在ys的容许范围内
    for k=1:PeakTime / h
        if y(k)>ydown
            AdjustTime = k * h;break;
        end
    end
end

if PeakValue > yup   %如果峰值超出了ys的容许范围
    for k=PeakTime / h:length(t)
        if (y(k-1)<=ydown && y(k)>=ydown) || (y(k-1)>=yup && y(k)<=yup)
            if max(y(k:length(t)))<=yup && min(y(k:length(t)))>=ydown
                AdjustTime = k * h;break;
            end
        end
    end
end

hold on;
plot([PeakTime,PeakTime],[0,y(PeakTime/h)],'--','color','red');

hold on;
plot([AdjustTime,AdjustTime],[0,y(AdjustTime/h)],'--','color','k');
%PlotXPosition(AdjustTime,h,y);

hold on;
plot([AdjustTime,tt],[ydown,ydown],'--','color','k');
hold on;
plot([AdjustTime,tt],[yup,yup],'--','color','k');

hold on;
plot([T0*h,T0*h],[0,y(T0)],'--','color','m');
hold on;
plot([T1*h,T1*h],[0,y(T1)],'--','color','m');

disp(['超调量=',num2str(sigma*100),'%'])
disp(['稳态误差=',num2str(ess)])
disp(['上升时间=',num2str(RiseTime),'s'])
disp(['峰值时间=',num2str(PeakTime),'s'])
disp(['调节时间=',num2str(AdjustTime),'s, 容许范围在ys的±',num2str(ppm*100),'%'])