### **Resolução de Problemas em VM com Windows no Azure**

#### **1. Diagnóstico Inicial do Problema**
   - **Passo 1**: Identifique o erro apresentado pela VM (ex: Tela Azul da Morte - BSOD, erro de inicialização, falha no boot).
   - **Passo 2**: Acesse o portal do Azure e verifique se a VM está acessível via RDP ou se há logs de falhas disponíveis no painel de **Monitoramento**.

#### **2. Expansão do Disco da VM (se necessário)**
   - **Passo 3**: Verifique o espaço disponível na VM para garantir que há espaço suficiente para os serviços do sistema.
   - **Passo 4**: Se necessário, expanda o disco seguindo os passos abaixo:
     1. No portal do Azure, selecione a VM.
     2. Vá até **Discos** e selecione o disco de SO (Sistema Operacional).
     3. Aumente o tamanho do disco conforme a necessidade.
     4. Após aumentar o tamanho no Azure, acesse a VM via RDP ou pelo Console Serial e use o **Gerenciamento de Disco** do Windows para expandir a partição no sistema operacional:
        - Clique com o botão direito na partição C:\ e selecione "Expandir Volume".
   
#### **3. Reparo da Inicialização Usando o Comando SFC**
   - **Passo 5**: Caso a VM esteja falhando ao iniciar, será necessário executar o **System File Checker (sfc)** para reparar arquivos corrompidos.
   - **Passo 6**: Acesse o disco da VM via Console Serial ou Conexão RDP, se possível.
   - **Passo 7**: Identifique as partições do disco para saber qual é a partição de inicialização (EFI) e qual contém o sistema operacional, utilizando o `diskpart`:
     1. Execute `diskpart` no prompt de comando.
     2. Use o comando `list volume` para identificar as partições.
     3. Atribua uma letra temporária à partição de inicialização (EFI), caso necessário, com o comando:
        ```bash
        assign letter=S
        ```

   - **Passo 8**: Execute o comando `sfc` para reparar o sistema:
     ```bash
     sfc /scannow /offbootdir=S:\ /offwindir=F:\windows
     ```

#### **4. Verificação do Reparo e Remoção da Letra de Partição (opcional)**
   - **Passo 9**: Após o reparo, reinicie a VM e verifique se ela inicia corretamente.
   - **Passo 10**: Se uma letra foi atribuída à partição EFI, remova-a para restaurar o estado original:
     1. Acesse o `diskpart` novamente.
     2. Selecione o volume da partição EFI com o comando `select volume X`.
     3. Remova a letra atribuída com o comando:
        ```bash
        remove letter=S
        ```

#### **5. Documentação e Encerramento**
   - **Passo 11**: Registre as etapas executadas no processo de reparo, incluindo a expansão do disco e o uso do `sfc`.
   - **Passo 12**: Informe o cliente ou superior responsável sobre a conclusão do processo e forneça detalhes da documentação de suporte, como links para artigos relevantes do **Microsoft Learn**.
   - https://learn.microsoft.com/pt-br/troubleshoot/azure/virtual-machines/windows/troubleshoot-guide-critical-process-died#fix-any-os-corruption

---
