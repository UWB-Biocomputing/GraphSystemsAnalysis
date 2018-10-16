% Burst origin movement analysis
origins = csvread('allBurstOriginXY.csv');
numbursts = size(origins,1);

% From visual inspection, bursts settle to a constant location after this
% number
transientbursts = 150;

% Basic plots
figure(1)
clf
plot(origins([1:transientbursts],1), origins([1:transientbursts],2), '*-');
xlabel('Burst x location')
ylabel('Burst y location')

figure(2)
clf
subplot(2,1,1)
plot([1:transientbursts],origins([1:transientbursts],1))
ylabel('Burst x location')
subplot(2,1,2)
plot([1:transientbursts],origins([1:transientbursts],2))
xlabel('Burst number')
ylabel('Burst y location')

% histograms
figure(3)
clf
subplot(2,1,1)
histogram(origins([1:transientbursts],1), 20)
xlabel('Burst x location')
subplot(2,1,2)
histogram(origins([1:transientbursts],2), 20)
xlabel('Burst y location')

% Bivariate histogram
figure(7)
clf
histogram2(origins([1:transientbursts],1), origins([1:transientbursts],2),10);
xlabel('Burst x location');
ylabel('Burst y location');
view(39, 48);

% 3D
figure(4)
clf
plot3(origins([1:transientbursts],1), origins([1:transientbursts],2), [1:transientbursts])
xlabel('Burst x location')
ylabel('Burst y location')
zlabel('Burst number')

% Univariate return maps
figure(5)
clf
plot(origins([1:transientbursts-1],1), origins([2:transientbursts],1), '*-')
xlabel('Burst x location i')
ylabel('Burst x location i+1')
figure(6)
clf
plot(origins([1:transientbursts-1],2), origins([2:transientbursts],2), '*-')
xlabel('Burst y location i')
ylabel('Burst y location i+1')

% Convert burst origin locations to polar coordinates, relative to (50, 50)
% and then do some more plots
originR = sqrt((origins(:,1)-50).^2 + (origins(:,2)-50).^2);
originTheta = atan2(origins(:,2)-50, origins(:,1)-50);

% Basic plots
figure(8)
clf
plot(originR(1:transientbursts), originTheta(1:transientbursts), '*-');
xlabel('Burst Radius');
ylabel('Burst Angle');

% Bivariate histogram
figure(9)
clf
histogram2(originR(1:transientbursts), originTheta(1:transientbursts),10);
xlabel('Burst Radius');
ylabel('Burst Angle');
view(39, 48);

% Look at power spectra
figure(10)
clf
subplot(2,1,1)
X = fft(origins([1:transientbursts],1));
X2 = abs(X/transientbursts);
X1 = X2(1:transientbursts/2+1);
X1(2:end-1) = 2*X1(2:end-1);
plot([1:length(X1)-1], X1(2:end));
ylabel('|X1(f)|');
subplot(2,1,2)
Y = fft(origins([1:transientbursts],2));
Y2 = abs(Y/transientbursts);
Y1 = Y2(1:transientbursts/2+1);
Y1(2:end-1) = 2*Y1(2:end-1);
plot([1:length(Y1)-1], Y1(2:end));
ylabel('|Y1(f)|');
xlabel('f (no units calculated)');

