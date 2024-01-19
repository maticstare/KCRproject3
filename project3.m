%Author: Matic Stare

%subject 20
[sigs,freq,tm]=rdsamp('eegmmidb/S020/S020R01.edf');
%exclude the last signal
sigs = sigs(:, 1:64);

%figure1
figure("Name", "Začetni signali");
plot(tm, sigs)

%figure2
figure("Name", "Začetni posamezni signali");
for i=1:64
    subplot(8,8,i);
    plot(tm, sigs(:,i));
    title(strcat("Komponenta ", int2str(i)));
end

%nastavitev maksimalnega števila iteracij na 5000
[icasig,A,W] = fastica(sigs', 'maxNumIterations', 5000);

sigsToRemove = input("Vnesi polje signalov, ki jih želiš odstraniti: ");

%sigsToRemove = 1:16; %signali nižjega indeksa imajo večji vpliv
A(:, sigsToRemove) = 0;

newSigs = (A*icasig)';

%figure3
figure("Name", "Signali po odstranitvi očesnih artefaktov");
plot(tm, newSigs)