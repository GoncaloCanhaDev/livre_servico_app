/// The app's privacy policy (Política de Privacidade), shown before an
/// account is created and from Definições. Change [privacyPolicyVersion]
/// with the text: accounts record the version they accepted.
library;

/// The date of this text; saved with each new account (`privacy_policy`).
const privacyPolicyVersion = '2026-11-01';

/// One part of the policy: a heading and its paragraphs.
typedef PolicySection = ({String title, List<String> paragraphs});

const privacyPolicy = <PolicySection>[
  (
    title: 'Sobre esta política',
    paragraphs: [
      'O Livre Serviço Companion é uma aplicação de apoio à organização do '
          'trabalho de equipas de loja: listas de abertura e de reposição, '
          'tarefas, receções de camião, inventários, pedidos e as pessoas da '
          'equipa. Esta política explica que dados pessoais guarda, para quê, '
          'quem os vê, durante quanto tempo e que direitos tem.',
      'A aplicação não é um produto da Jerónimo Martins nem do Pingo Doce.',
    ],
  ),
  (
    title: 'Responsável pelos dados',
    paragraphs: [
      'Responsável pelo tratamento: Gonçalo Canha.',
      'Contacto para questões de privacidade: goncalocanha.p@gmail.com.',
    ],
  ),
  (
    title: 'Que dados são guardados',
    paragraphs: [
      'Conta: o email e a palavra-passe (guardada cifrada pelo serviço de '
          'autenticação; ninguém, nem o administrador, a consegue ler), a loja '
          'a que pertence e a pessoa da lista da loja que é.',
      'Perfil de cada pessoa da loja: nome, fotografia, género, aniversário '
          '(só o dia e o mês), equipa, função (operador, segunda linha, '
          'supervisor, chefe de secção, gestor de área, secretária de loja, '
          'gerente de loja) e permanência, turno, número de colaborador, datas de '
          'início no Pingo Doce e na loja, tempo inteiro ou parcial, horas por '
          'semana, horário de entrada e saída, folgas, ausências (o tipo, por '
          'exemplo férias ou baixa, e as datas, sem outros pormenores) e '
          'notas.',
      'Registos de trabalho: o que é feito na aplicação (listas, tarefas, '
          'camiões, inventários, pedidos, informações da loja e contactos '
          'úteis), com quem o fez e quando.',
      'Avisos: o texto, quem o enviou, a quem e quando, e quem o viu e '
          'quando.',
      'Erros e sugestões: o que escrever em "Reportar erro ou sugestão", '
          'com o seu email, a sua loja, a versão da aplicação, o tipo de '
          'aparelho (Android, navegador...) e a data.',
      'Dados técnicos: a sessão iniciada neste aparelho, a data de cada '
          'alteração e a conta que a gravou. Não há publicidade, estatísticas '
          'de utilização nem qualquer seguimento da sua atividade.',
      'Não são guardados números de telefone nem o ano de nascimento.',
      'Não escreva nas notas nem noutros campos informações de saúde ou '
          'outros dados sensíveis.',
    ],
  ),
  (
    title: 'Para que servem',
    paragraphs: [
      'Para organizar o trabalho diário da loja: saber quem está a trabalhar, '
          'de folga ou ausente, distribuir e registar tarefas e listas, e '
          'contactar a equipa. Os dados não são vendidos nem cedidos a '
          'terceiros, nem usados para publicidade.',
      'Fundamento: o interesse legítimo na organização do trabalho da '
          'equipa da loja. Pode opor-se a este uso através do contacto '
          'indicado em "Responsável pelos dados".',
    ],
  ),
  (
    title: 'Quem vê os seus dados',
    paragraphs: [
      'Toda a gente da sua loja vê o nome, a fotografia, o género, o '
          'aniversário (dia e mês), a equipa e a função de cada pessoa, e os '
          'registos de trabalho.',
      'O resto do perfil vê-o só a própria pessoa, a chefia da sua equipa '
          '(o chefe de secção da equipa; os gestores de área e a secretária de '
          'loja, para todas as equipas menos a gerência; o gerente de loja, '
          'para todas) e o administrador da aplicação. Os outros aparelhos '
          'nem chegam a receber esses dados.',
      'Pode editar o seu nome, fotografia, aniversário, género e notas; as '
          'folgas e ausências são editadas pela chefia da sua equipa, e a '
          'equipa e a função por quem tiver uma função acima da sua.',
      'Um aviso só o vêem quem o enviou, as pessoas a quem foi enviado e o '
          'administrador da aplicação.',
      'Os erros e sugestões que enviar só os vê o administrador da '
          'aplicação.',
      'Ninguém de outra loja vê os dados da sua loja. Só entra na loja quem '
          'tiver o código da loja e for aprovado por um chefe de secção ou '
          'pela gerência.',
    ],
  ),
  (
    title: 'Onde ficam',
    paragraphs: [
      'Numa base de dados no seu aparelho (no telemóvel ou no navegador) e, com '
          'a conta iniciada, numa base de dados online no Supabase, na região '
          'da Europa Ocidental (Irlanda), dentro da União Europeia, com as '
          'fotografias num '
          'espaço privado. A ligação é sempre cifrada (HTTPS) e o servidor só '
          'entrega a cada conta o que ela pode ver.',
      'As mensagens que a aplicação abre no WhatsApp ficam sujeitas à '
          'política de privacidade do WhatsApp.',
    ],
  ),
  (
    title: 'Durante quanto tempo',
    paragraphs: [
      'Enquanto pertencer à loja. Para os aparelhos se manterem iguais, o que '
          'é apagado na aplicação fica online marcado como apagado, e as '
          'fotografias não são apagadas online. Pode pedir ao administrador que '
          'os apague definitivamente.',
      'Se mudar de loja, o seu perfil passa para a nova loja e os registos de '
          'trabalho ficam na loja anterior.',
    ],
  ),
  (
    title: 'Os seus direitos',
    paragraphs: [
      'Pode pedir acesso aos seus dados, corrigi-los, apagá-los, limitar ou '
          'opor-se ao seu uso e recebê-los num ficheiro, através do contacto '
          'indicado em "Responsável pelos dados". Pode também apresentar queixa à Comissão Nacional de '
          'Proteção de Dados (www.cnpd.pt).',
    ],
  ),
  (
    title: 'Alterações',
    paragraphs: [
      'Esta é a versão de $privacyPolicyVersion. Se a política mudar, a nova '
          'versão fica disponível na aplicação, em Definições.',
    ],
  ),
];
