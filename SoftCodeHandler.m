function output_args = SoftCodeHandler(softCode)
%soft codes 1-10 reserved for odor delivery
%soft code 11-20 reserved for pulse pal sound delivery

global BpodSystem
global TaskParameters

if softCode < 11 %for olfactory
    if BpodSystem.Data.Custom.OlfactometerStartup %if there has been a non-auditory trial and thus olfactometer initialized
        
        firstbank = ['Bank' num2str(TaskParameters.GUI.OdorA_bank)];
        secbank = ['Bank' num2str(TaskParameters.GUI.OdorB_bank)];
        
        if softCode < 9
            if ~BpodSystem.EmulatorMode
                CommandValve = Valves2EthernetString(firstbank, softCode, secbank, softCode); % odorPair := desired valve number
                TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValve);
            end
        elseif softCode == 9
            nextTrial = numel(BpodSystem.Data.Custom.TrialNumber) + 2;
            OdorA_flow = BpodSystem.Data.Custom.OdorFracA(nextTrial);
            OdorB_flow = 100 - OdorA_flow;
            if ~BpodSystem.EmulatorMode
                SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorA_bank, OdorA_flow)
                SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorB_bank, OdorB_flow)
            end
        end
    end
end

if softCode > 10 && softCode < 20 %for auditory
    if ~BpodSystem.EmulatorMode
        if softCode == 11 %noise on chan 1
            s = ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamFeedback);
            SendCustomPulseTrain(1,cumsum(randi(19,1,301))/10000,(rand(1,301)-.5)*20); % White(?) noise on channel 1
            TriggerPulsePal('1000');
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
        elseif softCode == 12 %beep on chan 2
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamFeedback);
            SendCustomPulseTrain(2,0:.001:.30,(ones(1,301)*10));  % Beep on channel 2
            TriggerPulsePal('0100');
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
        end
    end
end
% switch odorID
%     case 0
%         CommandValveMinOil = Valves2EthernetString(firstbank, 2, secbank, 2);
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveMinOil);
%     case 1
%         CommandValveScent = Valves2EthernetString(firstbank, 1, secbank, 1); % From RechiaOlfactometer plugin. Simultaneously sets banks 1 and 2 to valve 1
%         TCPWrite(BpodSystem.Data.Custom.OlfIp, 3336, CommandValveScent);
end

