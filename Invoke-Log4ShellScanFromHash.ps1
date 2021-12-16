[CmdletBinding()]
PARAM(
    [Parameter(Mandatory=$False)]
    [string[]]
    $Computername = $ENV:COMPUTERNAME,

    [Parameter(Mandatory=$False)]
    [System.Management.Automation.PSCredential]
    $Credential,

    [Parameter(Mandatory=$False)]
    [int]
    $MAXJOBS = 50,

    [Parameter(Mandatory=$False)]
    [int]
    $TimeoutMinutes = 20
)
BEGIN {
    $ScriptBlock = {
        Function New-Runspace {
            [cmdletbinding()]
            param(
                [string]$BaseDir,
                [switch]$Recurse
            )
            $ScriptBlock = {
                Param(
                    [string]$BaseDir,
                    [switch]$Recurse
                )
                begin{
                    Function Get-SpecificChildItem {
                        [CmdletBinding()]
                        Param(
                            [parameter(Mandatory=$true, ValueFromPipeline=$true)]
                            [string]$Path,
                            [switch]$Recurse
                        )
                        begin {
                            $List = 'sha256hash,Name,filename
                            "39a495034d37c7934b64a9aa686ea06b61df21aa222044cc50a47d6903ba1ca8","log4j 2.0-rc1","JndiLookup.class"
                            "a03e538ed25eff6c4fe48aabc5514e5ee687542f29f2206256840e74ed59bcd2","log4j 2.0-rc2","JndiLookup.class"
                            "964fa0bf8c045097247fa0c973e0c167df08720409fd9e44546e0ceda3925f3e","log4j 2.0.1","JndiLookup.class"
                            "9626798cce6abd0f2ffef89f1a3d0092a60d34a837a02bbe571dbe00236a2c8c","log4j 2.0.2","JndiLookup.class"
                            "fd6c63c11f7a6b52eff04be1de3477c9ddbbc925022f7216320e6db93f1b7d29","log4j 2.0","JndiLookup.class"
                            "03c77cca9aeff412f46eaf1c7425669e37008536dd52f1d6f088e80199e4aae7","log4j 2.4-2.11.2","JndiManager$1.class"
                            "1584b839cfceb33a372bb9e6f704dcea9701fa810a9ba1ad3961615a5b998c32","log4j 2.7-2.8.1","JndiManager.class"
                            "1fa92c00fa0b305b6bbe6e2ee4b012b588a906a20a05e135cbe64c9d77d676de","log4j 2.12.0-2.12.1","JndiManager.class"
                            "293d7e83d4197f0496855f40a7745cfcdd10026dc057dfc1816de57295be88a6","log4j 2.9.0-2.11.2","JndiManager.class"
                            "3bff6b3011112c0b5139a5c3aa5e698ab1531a2f130e86f9e4262dd6018916d7","log4j 2.4-2.5","JndiManager.class"
                            "547883afa0aa245321e6b1aaced24bc10d73d5af4974d951e2bd53b017e2d4ab","log4j 2.14.0-2.14.1","JndiManager$JndiManagerFactory.class"
                            "620a713d908ece7fb09b7d34c2b0461e1c366704da89ea20eb78b73116c77f23","log4j 2.1-2.3","JndiManager$1.class"
                            "632a69aef3bc5012f61093c3d9b92d6170fdc795711e9fed7f5388c36e3de03d","log4j 2.8.2","JndiManager$JndiManagerFactory.class"
                            "635ccd3aaa429f3fea31d84569a892b96a02c024c050460d360cc869bcf45840","log4j 2.9.1-2.10.0","JndiManager$JndiManagerFactory.class"
                            "6540d5695ddac8b0a343c2e91d58316cfdbfdc5b99c6f3f91bc381bc6f748246","log4j 2.6-2.6.2","JndiManager.class"
                            "764b06686dbe06e3d5f6d15891250ab04073a0d1c357d114b7365c70fa8a7407","log4j 2.8.2","JndiManager.class"
                            "77323460255818f4cbfe180141d6001bfb575b429e00a07cbceabd59adf334d6","log4j 2.14.0-2.14.1","JndiManager.class"
                            "8abaebc4d09926cd12b5269c781b64a7f5a57793c54dc1225976f02ba58343bf","log4j 2.13.0-2.13.3","JndiManager$JndiManagerFactory.class"
                            "91e58af100aface711700562b5002c5d397fb35d2a95d5704db41461ac1ad8fd","log4j 2.1-2.3","JndiManager$JndiManagerFactory.class"
                            "ae950f9435c0ef3373d4030e7eff175ee11044e584b7f205b7a9804bbe795f9c","log4j 2.1-2.3","JndiManager.class"
                            "aec7ea2daee4d6468db2df25597594957a06b945bcb778bbcd5acc46f17de665","log4j 2.4-2.6.2","JndiManager$JndiManagerFactory.class"
                            "b8af4230b9fb6c79c5bf2e66a5de834bc0ebec4c462d6797258f5d87e356d64b","log4j 2.7-2.8.1","JndiManager$JndiManagerFactory.class"
                            "c3e95da6542945c1a096b308bf65bbd7fcb96e3d201e5a2257d85d4dedc6a078","log4j 2.13.0-2.13.3","JndiManager.class"
                            "e4906e06c4e7688b468524990d9bb6460d6ef31fe938e01561f3f93ab5ca25a6","log4j 2.8.2-2.12.0","JndiManager$1.class"
                            "fe15a68ef8a75a3f9d3f5843f4b4a6db62d1145ef72937ed7d6d1bbcf8ec218f","log4j 2.12.0-2.12.1","JndiManager$JndiManagerFactory.class"
                            "0ebc263ba66a7452d3dfc15760c560f930d835164914a1340d741838e3165dbb","log4j 2.4-2.5","MessagePatternConverter.class"
                            "52b5574bad677030c56c1a386362840064d347523e61e59ca1c55faf7e998986","log4j 2.12","MessagePatternConverter.class"
                            "5c328eedefcb28512ff5d9a7556741dd159f0b13e1c0c52edc958d9821b8d2c5","log4j 2.6","MessagePatternConverter.class"
                            "791a12347e62d9884c4d6f8e285098fedaf3bcdf591af3e4449923191588d43c","log4j 2.8-2.9","MessagePatternConverter.class"
                            "8d5e886175b66ec2de5b61113fdaf06c50e1070cad1fb9150258e01d84d13c4b","log4j 2.13","MessagePatternConverter.class"
                            "95b385ebc65843315aeae33551e7bbdad886e9e9465ea8d3179cd74344b37984","log4j 2.10-2.11","MessagePatternConverter.class"
                            "a36c2e78cef7c2ddcc4ebbb11c085e85989eb93f9d19bd6254913b13dfe7c58e","log4j 2.0-2.3","MessagePatternConverter.class"
                            "a3a65f2c5bc0dd62df115a0d9ac7140793c61b65bbbac313a526a3b50724a8c7","log4j 2.8.2","MessagePatternConverter.class"
                            "ee41ae7ae80f5c533548a89c6d6e112df609c838b901daea99ac88ccda2a5da1","log4j 2.7","MessagePatternConverter.class"
                            "f0a869f7da9b17d0a23d0cb0e13c65afa5e42e9567b47603a8fc0debc7ef193c","log4j 2.14","MessagePatternConverter.class"
                            "f8baca973f1874b76cfaed0f4c17048b1ac0dee364abfdfeeec62de3427def50","log4j 2.0-rc1","MessagePatternConverter.class"
                            "ce69c1ea49c60f3be90cb9c86d7220af86e5d2fbc08fd7232da7278926e4f881","log4j 2.0-alpha1/alpha2/beta1","MessagePatternConverter.class"
                            "963ee03ebe020703fea27f657496d35edeac264beebeb14bfcd9d3350343c0bf","log4j 2.0-beta2/beta3","MessagePatternConverter.class"
                            "be8f32ed92f161df72248dcbaaf761c812ddbb59434abfd5c87482e9e0bd983c","log4j 2.0-beta4","MessagePatternConverter.class"
                            "9a54a585ed491573e80e0b32e964e5eb4d6c4068d2abffff628e3c69ef9102cf","log4j 2.0-beta5","MessagePatternConverter.class"
                            "357120b06f61475033d152505c3d43a57c9a9bdc05b835d0939f1662b48fc6c3","log4j 2.0-beta6/beta7/beta8","MessagePatternConverter.class"
                            "6adb3617902180bdf9cbcfc08b5a11f3fac2b44ef1828131296ac41397435e3d","log4j 1.2.4","SocketNode.class"
                            "3ef93e9cb937295175b75182e42ba9a0aa94f9f8e295236c9eef914348efeef0","log4j 1.2.6-1.2.9","SocketNode.class"
                            "bee4a5a70843a981e47207b476f1e705c21fc90cb70e95c3b40d04a2191f33e9","log4j 1.2.8","SocketNode.class"
                            "7b996623c05f1a25a57fb5b43c519c2ec02ec2e647c2b97b3407965af928c9a4","log4j 1.2.15","SocketNode.class"
                            "688a3dadfb1c0a08fb2a2885a356200eb74e7f0f26a197d358d74f2faf6e8f46","log4j 1.2.16","SocketNode.class"
                            "8ef0ebdfbf28ec14b2267e6004a8eea947b4411d3c30d228a7b48fae36431d74","log4j 1.2.17","SocketNode.class"
                            "d778227b779f8f3a2850987e3cfe6020ca26c299037fdfa7e0ac8f81385963e6","log4j 1.2.11","SocketNode.class"
                            "ed5d53deb29f737808521dd6284c2d7a873a59140e702295a80bd0f26988f53a","log4j 1.2.5","SocketNode.class"
                            "f3b815a2b3c74851ff1b94e414c36f576fbcdf52b82b805b2e18322b3f5fc27c","log4j 1.2.12","SocketNode.class"
                            "fbda3cfc5853ab4744b853398f2b3580505f5a7d67bfb200716ef6ae5be3c8b7","log4j 1.2.13-1.2.14","SocketNode.class"
                            "bf4f41403280c1b115650d470f9b260a5c9042c04d9bcc2a6ca504a66379b2d6","./apache-log4j-2.0-alpha2-bin/log4j-core-2.0-alpha2.jar","log4j-core-2.0-alpha2.jar"
                            "58e9f72081efff9bdaabd82e3b3efe5b1b9f1666cefe28f429ad7176a6d770ae","./apache-log4j-2.0-beta1-bin/log4j-core-2.0-beta1.jar","log4j-core-2.0-beta1.jar"
                            "ed285ad5ac6a8cf13461d6c2874fdcd3bf67002844831f66e21c2d0adda43fa4","./apache-log4j-2.0-beta2-bin/log4j-core-2.0-beta2.jar","log4j-core-2.0-beta2.jar"
                            "dbf88c623cc2ad99d82fa4c575fb105e2083465a47b84d64e2e1a63e183c274e","./apache-log4j-2.0-beta3-bin/log4j-core-2.0-beta3.jar","log4j-core-2.0-beta3.jar"
                            "a38ddff1e797adb39a08876932bc2538d771ff7db23885fb883fec526aff4fc8","./apache-log4j-2.0-beta4-bin/log4j-core-2.0-beta4.jar","log4j-core-2.0-beta4.jar"
                            "7d86841489afd1097576a649094ae1efb79b3147cd162ba019861dfad4e9573b","./apache-log4j-2.0-beta5-bin/log4j-core-2.0-beta5.jar","log4j-core-2.0-beta5.jar"
                            "4bfb0d5022dc499908da4597f3e19f9f64d3cc98ce756a2249c72179d3d75c47","./apache-log4j-2.0-beta6-bin/log4j-core-2.0-beta6.jar","log4j-core-2.0-beta6.jar"
                            "473f15c04122dad810c919b2f3484d46560fd2dd4573f6695d387195816b02a6","./apache-log4j-2.0-beta7-bin/log4j-core-2.0-beta7.jar","log4j-core-2.0-beta7.jar"
                            "b3fae4f84d4303cdbad4696554b4e8d2381ad3faf6e0c3c8d2ce60a4388caa02","./apache-log4j-2.0-beta8-bin/log4j-core-2.0-beta8.jar","log4j-core-2.0-beta8.jar"
                            "dcde6033b205433d6e9855c93740f798951fa3a3f252035a768d9f356fde806d","./apache-log4j-2.0-beta9-bin/log4j-core-2.0-beta9.jar","log4j-core-2.0-beta9.jar"
                            "85338f694c844c8b66d8a1b981bcf38627f95579209b2662182a009d849e1a4c","./apache-log4j-2.0-bin/log4j-core-2.0.jar","log4j-core-2.0.jar"
                            "db3906edad6009d1886ec1e2a198249b6d99820a3575f8ec80c6ce57f08d521a","./apache-log4j-2.0-rc1-bin/log4j-core-2.0-rc1.jar","log4j-core-2.0-rc1.jar"
                            "ec411a34fee49692f196e4dc0a905b25d0667825904862fdba153df5e53183e0","./apache-log4j-2.0-rc2-bin/log4j-core-2.0-rc2.jar","log4j-core-2.0-rc2.jar"
                            "a00a54e3fb8cb83fab38f8714f240ecc13ab9c492584aa571aec5fc71b48732d","./apache-log4j-2.0.1-bin/log4j-core-2.0.1.jar","log4j-core-2.0.1.jar"
                            "c584d1000591efa391386264e0d43ec35f4dbb146cad9390f73358d9c84ee78d","./apache-log4j-2.0.2-bin/log4j-core-2.0.2.jar","log4j-core-2.0.2.jar"
                            "8bdb662843c1f4b120fb4c25a5636008085900cdf9947b1dadb9b672ea6134dc","./apache-log4j-2.1-bin/log4j-core-2.1.jar","log4j-core-2.1.jar"
                            "c830cde8f929c35dad42cbdb6b28447df69ceffe99937bf420d32424df4d076a","./apache-log4j-2.2-bin/log4j-core-2.2.jar","log4j-core-2.2.jar"
                            "6ae3b0cb657e051f97835a6432c2b0f50a651b36b6d4af395bbe9060bb4ef4b2","./apache-log4j-2.3-bin/log4j-core-2.3.jar","log4j-core-2.3.jar"
                            "535e19bf14d8c76ec00a7e8490287ca2e2597cae2de5b8f1f65eb81ef1c2a4c6","./apache-log4j-2.4-bin/log4j-core-2.4.jar","log4j-core-2.4.jar"
                            "42de36e61d454afff5e50e6930961c85b55d681e23931efd248fd9b9b9297239","./apache-log4j-2.4.1-bin/log4j-core-2.4.1.jar","log4j-core-2.4.1.jar"
                            "4f53e4d52efcccdc446017426c15001bb0fe444c7a6cdc9966f8741cf210d997","./apache-log4j-2.5-bin/log4j-core-2.5.jar","log4j-core-2.5.jar"
                            "df00277045338ceaa6f70a7b8eee178710b3ba51eac28c1142ec802157492de6","./apache-log4j-2.6-bin/log4j-core-2.6.jar","log4j-core-2.6.jar"
                            "28433734bd9e3121e0a0b78238d5131837b9dbe26f1a930bc872bad44e68e44e","./apache-log4j-2.6.1-bin/log4j-core-2.6.1.jar","log4j-core-2.6.1.jar"
                            "cf65f0d33640f2cd0a0b06dd86a5c6353938ccb25f4ffd14116b4884181e0392","./apache-log4j-2.6.2-bin/log4j-core-2.6.2.jar","log4j-core-2.6.2.jar"
                            "5bb84e110d5f18cee47021a024d358227612dd6dac7b97fa781f85c6ad3ccee4","./apache-log4j-2.7-bin/log4j-core-2.7.jar","log4j-core-2.7.jar"
                            "ccf02bb919e1a44b13b366ea1b203f98772650475f2a06e9fac4b3c957a7c3fa","./apache-log4j-2.8-bin/log4j-core-2.8.jar","log4j-core-2.8.jar"
                            "815a73e20e90a413662eefe8594414684df3d5723edcd76070e1a5aee864616e","./apache-log4j-2.8.1-bin/log4j-core-2.8.1.jar","log4j-core-2.8.1.jar"
                            "10ef331115cbbd18b5be3f3761e046523f9c95c103484082b18e67a7c36e570c","./apache-log4j-2.8.2-bin/log4j-core-2.8.2.jar","log4j-core-2.8.2.jar"
                            "dc815be299f81c180aa8d2924f1b015f2c46686e866bc410e72de75f7cd41aae","./apache-log4j-2.9.0-bin/log4j-core-2.9.0.jar","log4j-core-2.9.0.jar"
                            "9275f5d57709e2204900d3dae2727f5932f85d3813ad31c9d351def03dd3d03d","./apache-log4j-2.9.1-bin/log4j-core-2.9.1.jar","log4j-core-2.9.1.jar"
                            "f35ccc9978797a895e5bee58fa8c3b7ad6d5ee55386e9e532f141ee8ed2e937d","./apache-log4j-2.10.0-bin/log4j-core-2.10.0.jar","log4j-core-2.10.0.jar"
                            "5256517e6237b888c65c8691f29219b6658d800c23e81d5167c4a8bbd2a0daa3","./apache-log4j-2.11.0-bin/log4j-core-2.11.0.jar","log4j-core-2.11.0.jar"
                            "d4485176aea67cc85f5ccc45bb66166f8bfc715ae4a695f0d870a1f8d848cc3d","./apache-log4j-2.11.1-bin/log4j-core-2.11.1.jar","log4j-core-2.11.1.jar"
                            "3fcc4c1f2f806acfc395144c98b8ba2a80fe1bf5e3ad3397588bbd2610a37100","./apache-log4j-2.11.2-bin/log4j-core-2.11.2.jar","log4j-core-2.11.2.jar"
                            "057a48fe378586b6913d29b4b10162b4b5045277f1be66b7a01fb7e30bd05ef3","./apache-log4j-2.12.0-bin/log4j-core-2.12.0.jar","log4j-core-2.12.0.jar"
                            "5dbd6bb2381bf54563ea15bc9fbb6d7094eaf7184e6975c50f8996f77bfc3f2c","./apache-log4j-2.12.1-bin/log4j-core-2.12.1.jar","log4j-core-2.12.1.jar"
                            "c39b0ea14e7766440c59e5ae5f48adee038d9b1c7a1375b376e966ca12c22cd3","./apache-log4j-2.13.0-bin/log4j-core-2.13.0.jar","log4j-core-2.13.0.jar"
                            "6f38a25482d82cd118c4255f25b9d78d96821d22bab498cdce9cda7a563ca992","./apache-log4j-2.13.1-bin/log4j-core-2.13.1.jar","log4j-core-2.13.1.jar"
                            "54962835992e303928aa909730ce3a50e311068c0960c708e82ab76701db5e6b","./apache-log4j-2.13.2-bin/log4j-core-2.13.2.jar","log4j-core-2.13.2.jar"
                            "e5e9b0f8d72f4e7b9022b7a83c673334d7967981191d2d98f9c57dc97b4caae1","./apache-log4j-2.13.3-bin/log4j-core-2.13.3.jar","log4j-core-2.13.3.jar"
                            "68d793940c28ddff6670be703690dfdf9e77315970c42c4af40ca7261a8570fa","./apache-log4j-2.14.0-bin/log4j-core-2.14.0.jar","log4j-core-2.14.0.jar"
                            "9da0f5ca7c8eab693d090ae759275b9db4ca5acdbcfe4a63d3871e0b17367463","./apache-log4j-2.14.1-bin/log4j-core-2.14.1.jar","log4j-core-2.14.1.jar"
                            "006fc6623fbb961084243cfc327c885f3c57f2eba8ee05fbc4e93e5358778c85","./log4j-2.0-alpha1/log4j-core-2.0-alpha1.jar","log4j-core-2.0-alpha1.jar"
                            "a00a54e3fb8cb83fab38f8714f240ecc13ab9c492584aa571aec5fc71b48732d","log4j-core-2.0.1.jar","log4j-core-2.0.1.jar"
                            "c584d1000591efa391386264e0d43ec35f4dbb146cad9390f73358d9c84ee78d","log4j-core-2.0.2.jar","log4j-core-2.0.2.jar"
                            "85338f694c844c8b66d8a1b981bcf38627f95579209b2662182a009d849e1a4c","log4j-core-2.0.jar","log4j-core-2.0.jar"
                            "22b58febab566eddd5d4863f09dad4d5cc57677b6d4be745e3c6ce547124a66d","log4j-core-2.10.0.jar","log4j-core-2.10.0.jar"
                            "c32029b32da3d8cf2feca0790a4bc2331ea7eb62ab368a8980b90c7d8c8101e0","log4j-core-2.11.0.jar","log4j-core-2.11.0.jar"
                            "a20c34cdac4978b76efcc9d0db66e95600bd807c6a0bd3f5793bcb45d07162ec","log4j-core-2.11.1.jar","log4j-core-2.11.1.jar"
                            "d4748cd5d8d67f513de7634fa202740490d7e0ab546f4bf94e5c4d4a11e3edbc","log4j-core-2.11.2.jar","log4j-core-2.11.2.jar"
                            "8818f82570d3f509cfb27c209b9a8df6f188857b7462951a61a137be09cf3463","log4j-core-2.12.0.jar","log4j-core-2.12.0.jar"
                            "885e31a14fc71cb4849e93564d26a221c685a789379ef63cb2d082cedf3c2235","log4j-core-2.12.1.jar","log4j-core-2.12.1.jar"
                            "82e91afe0c5628b32ae99dd6965878402c668773fbd49b45b2b8c06a426c5bbb","log4j-core-2.13.0.jar","log4j-core-2.13.0.jar"
                            "88ebd503b35a0debe18c2707db9de33a8c6d96491270b7f02dd086b8072426b2","log4j-core-2.13.1.jar","log4j-core-2.13.1.jar"
                            "268dc17d3739992d4d1ca2c27f94630fb203a40d07e9ad5dfae131d4e3fa9764","log4j-core-2.13.2.jar","log4j-core-2.13.2.jar"
                            "9529c55814264ab96b0eeba2920ac0805170969c994cc479bd3d4d7eb24a35a8","log4j-core-2.13.3.jar","log4j-core-2.13.3.jar"
                            "f04ee9c0ac417471d9127b5880b96c3147249f20674a8dbb88e9949d855382a8","log4j-core-2.14.0.jar","log4j-core-2.14.0.jar"
                            "ade7402a70667a727635d5c4c29495f4ff96f061f12539763f6f123973b465b0","log4j-core-2.14.1.jar","log4j-core-2.14.1.jar"
                            "8bdb662843c1f4b120fb4c25a5636008085900cdf9947b1dadb9b672ea6134dc","log4j-core-2.1.jar","log4j-core-2.1.jar"
                            "c830cde8f929c35dad42cbdb6b28447df69ceffe99937bf420d32424df4d076a","log4j-core-2.2.jar","log4j-core-2.2.jar"
                            "6ae3b0cb657e051f97835a6432c2b0f50a651b36b6d4af395bbe9060bb4ef4b2","log4j-core-2.3.jar","log4j-core-2.3.jar"
                            "42de36e61d454afff5e50e6930961c85b55d681e23931efd248fd9b9b9297239","log4j-core-2.4.1.jar","log4j-core-2.4.1.jar"
                            "535e19bf14d8c76ec00a7e8490287ca2e2597cae2de5b8f1f65eb81ef1c2a4c6","log4j-core-2.4.jar","log4j-core-2.4.jar"
                            "4f53e4d52efcccdc446017426c15001bb0fe444c7a6cdc9966f8741cf210d997","log4j-core-2.5.jar","log4j-core-2.5.jar"
                            "28433734bd9e3121e0a0b78238d5131837b9dbe26f1a930bc872bad44e68e44e","log4j-core-2.6.1.jar","log4j-core-2.6.1.jar"
                            "cf65f0d33640f2cd0a0b06dd86a5c6353938ccb25f4ffd14116b4884181e0392","log4j-core-2.6.2.jar","log4j-core-2.6.2.jar"
                            "df00277045338ceaa6f70a7b8eee178710b3ba51eac28c1142ec802157492de6","log4j-core-2.6.jar","log4j-core-2.6.jar"
                            "5bb84e110d5f18cee47021a024d358227612dd6dac7b97fa781f85c6ad3ccee4","log4j-core-2.7.jar","log4j-core-2.7.jar"
                            "815a73e20e90a413662eefe8594414684df3d5723edcd76070e1a5aee864616e","log4j-core-2.8.1.jar","log4j-core-2.8.1.jar"
                            "10ef331115cbbd18b5be3f3761e046523f9c95c103484082b18e67a7c36e570c","log4j-core-2.8.2.jar","log4j-core-2.8.2.jar"
                            "ccf02bb919e1a44b13b366ea1b203f98772650475f2a06e9fac4b3c957a7c3fa","log4j-core-2.8.jar","log4j-core-2.8.jar"
                            "fb086e42c232d560081d5d76b6b9e0979e5693e5de76734cad5e396dd77278fd","log4j-core-2.9.0.jar","log4j-core-2.9.0.jar"
                            "dc435b35b5923eb05afe30a24f04e9a0a5372da8e76f986efe8508b96101c4ff","log4j-core-2.9.1.jar","log4j-core-2.9.1.jar"' | ConvertFrom-Csv
                            <# removing non-vulnerable files
                            "6d269bc8594faa1fe7514a5e9ab98ed601ef54d1c2dceb8b8fc29a740850376b","log4j-api-2.0.1.jar","log4j-api-2.0.1.jar"
                            "8fd52adf822d3a398ca000552ecf988d8e87fb7d380b5b62358033ef25833253","log4j-api-2.0.2.jar","log4j-api-2.0.2.jar"
                            "576ecca34560abb43be01d45fa994b60ec48b3f1c932b0a51d2f8a8af4ad9800","log4j-api-2.0.jar","log4j-api-2.0.jar"
                            "26af661e5c37cfe233cdec402e8a5c0bd112e03d3b6cf12b0d9db7ee7f6fbdd9","log4j-api-2.10.0.jar","log4j-api-2.10.0.jar"
                            "fa5828950269b0ae425c96d889f18f40b336e9fa886841ae06bb9225511f1217","log4j-api-2.11.0.jar","log4j-api-2.11.0.jar"
                            "493b37b5a6c49c4f5fb609b966375e4dc1783df436587584ca1dc7e861d0742b","log4j-api-2.11.1.jar","log4j-api-2.11.1.jar"
                            "09b8ce1740491deefdb3c336855822b64609b457c2966d806348456c0da261d2","log4j-api-2.11.2.jar","log4j-api-2.11.2.jar"
                            "e5e5ccfe91b1875ce2c407699f82ba4ca42f93f39b5575489d312e637ec57bfe","log4j-api-2.12.0.jar","log4j-api-2.12.0.jar"
                            "429534d03bdb728879ab551d469e26f6f7ff4c8a8627f59ac68ab6ef26063515","log4j-api-2.12.1.jar","log4j-api-2.12.1.jar"
                            "5650d84d57373de6295934fa02b2022020567082cceb50fbb34fcb7ce9a52d1f","log4j-api-2.13.0.jar","log4j-api-2.13.0.jar"
                            "307fffc2623d010e3fe67d9f6b101c14bae33ec310e5f56960d491885fd59630","log4j-api-2.13.1.jar","log4j-api-2.13.1.jar"
                            "4dd502df82236031b8d32a243e6b210a6b9517333d9fe8116130e7743b6c038f","log4j-api-2.13.2.jar","log4j-api-2.13.2.jar"
                            "2b4b1965c9dce7f3732a0fbf5c8493199c1e6bf8cf65c3e235b57d98da5f36af","log4j-api-2.13.3.jar","log4j-api-2.13.3.jar"
                            "9791ac85aa3cdad633e512192766f84995eddf4db188cc42facec52a0dae15e8","log4j-api-2.14.0.jar","log4j-api-2.14.0.jar"
                            "8caf58db006c609949a0068110395a33067a2bad707c3da35e959c0473f9a916","log4j-api-2.14.1.jar","log4j-api-2.14.1.jar"
                            "2bb344cdc2a693c9f35ede6a82b8a576e253ec956246e0f74fded4ccbec074fb","log4j-api-2.1.jar","log4j-api-2.1.jar"
                            "54082f53119df5b49864f2e75b42b9622913b3a765bcbb7049524289a6f83089","log4j-api-2.2.jar","log4j-api-2.2.jar"
                            "d343479d0e3d39733bd0128ad38eaa100f62671fc3dbcfac34e1c812f5d0ef2b","log4j-api-2.3.jar","log4j-api-2.3.jar"
                            "961f2ccce1b30d812ae1477130b221ff495d8616ae79e62c7a0636933e82f5e0","log4j-api-2.4.1.jar","log4j-api-2.4.1.jar"
                            "afc5c80e6bd6ca036f0df4ed071d5e4ef19f1f1b53665065a3c0fb1132ad4d4c","log4j-api-2.4.jar","log4j-api-2.4.jar"
                            "9452e85177f69535ca093cbe2df3e8604344d58f729db70fb9e3009e80684251","log4j-api-2.5.jar","log4j-api-2.5.jar"
                            "5439c842b73e9136327cabbaa3ebb4a1de979f7ec3072b9eacf072554ae1d3e1","log4j-api-2.6.1.jar","log4j-api-2.6.1.jar"
                            "a7ce4e774b0100ffa0f87a2456ea6768c42cb50795e931bb51dbcdbbce974ec8","log4j-api-2.6.2.jar","log4j-api-2.6.2.jar"
                            "802cb046b9ba806b264c8423dd8359d9f7ed4d06a6d4a746e378d3e3e1483137","log4j-api-2.6.jar","log4j-api-2.6.jar"
                            "2119221bfc18bc8b13f807a1eaa9bc12324efd0c6fb2a993a0a2445d4b47c263","log4j-api-2.7.jar","log4j-api-2.7.jar"
                            "1205ab764b1326f7d96d99baa4a4e12614599bf3d735790947748ee116511fa2","log4j-api-2.8.1.jar","log4j-api-2.8.1.jar"
                            "7ba734f8f6d7c5a590bdda572d44faa5b3693022039dad892feedd4a1a09d9c1","log4j-api-2.8.2.jar","log4j-api-2.8.2.jar"
                            "2fcba95a51e756d6ce1c359745b07909d8539fee9f8d825998204eef90f46361","log4j-api-2.8.jar","log4j-api-2.8.jar"
                            "2c351cfcd5a1206a4aa20f0ad9e29a6b6b2edde7b8871de8eb09e8bd17cde94a","log4j-api-2.9.0.jar","log4j-api-2.9.0.jar"
                            "cad088ba9c43e1a13bba0a3d44bec1ef42bd22fdf12dad2bd73a22666bfbd009","log4j-api-2.9.1.jar","log4j-api-2.9.1.jar"
                            #>
                            # Added alternate SH256 hashes from https://github.com/lgtux/find_log4j/blob/main/logj4_sha256sums.txt
                            # Primary list: https://github.com/lunasec-io/lunasec/blob/master/tools/log4shell/constants/vulnerablehashes.go

                            $PSVersionMajor = $PSVersionTable.PSVersion.Major
                            $HashList = $List.sha256hash
                            if ( $PSVersionMajor -le 3 ) {
                                $sha = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
                            }
                        } # BEGIN
                        process {
                            $gciparams = @{
                                Path = $Path
                                Force = $True
                                Include = $($List | Select-Object -ExpandProperty filename | Sort-Object -Unique)
                                ErrorAction = "SilentlyContinue"
                            }
                            if ( $Recurse -ne $False ) {
                                [void]$gciparams.Add("Recurse",$True)
                            }
                            else {
                                $gciParams.Path = Join-Path $gciparams.path "*"
                            }

                            Get-ChildItem @gciparams | ForEach-Object {
                                if ( $PSVersionMajor -gt 3 ) {
                                    $FileHash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
                                }
                                else {
                                    $FileHash = [System.BitConverter]::ToString($sha.ComputeHash([System.IO.File]::ReadAllBytes($_.FullName))).Replace("-","")
                                }
                                Write-Verbose "FileHash for $($_.Fullname) is $FileHash"

                                if ( $FileHash -in $HashList) {
                                    $_ | Select-Object -Property @{N="Computername";E={$ENV:COMPUTERNAME}}, Name, FullName, @{N="FileHash";E={$FileHash}}
                                }
                            }
                        }
                        end {}
                    } # Function Get-SpecificChildItem
                }
                process {
                    if ( $Recurse ) {
                        Get-SpecificChildItem -Path $BaseDir -Recurse
                    }
                    else {
                        Get-SpecificChildItem -Path $BaseDir
                    }
                }
            } # ScriptBlock
            $PowerShell = [PowerShell]::Create()
            $PowerShell.RunspacePool = $Global:RunspacePool
            # What to run in the thread
            [void]$PowerShell.AddScript($ScriptBlock)
            # Parameters
            [void]$PowerShell.AddParameter("BaseDir",$BaseDir)
            if ( $Recurse ) {
                [void]$PowerShell.AddParameter("Recurse",$True)
            }
            
            # Save a reference to the thread, with meta data
            [void]$Global:JobThreads.Add((
                New-Object -Type PSCustomObject -Property @{
                    PowerShell  = $PowerShell
                    AsyncResult = $PowerShell.BeginInvoke()
                    BaseDir     = $BaseDir
                }
            ))
        } # Function New-Runspace

        $AllFiles = [System.Collections.ArrayList]@()
        $Global:JobThreads = [System.Collections.ArrayList]@()

        # Set up runspace factory
        $MAX_THREADS          = [int]$ENV:NUMBER_OF_PROCESSORS + 1
        if ($MAX_THREADS -lt 5 ) { $MAX_THREADS = 5 }
        Write-Verbose "Max Threads: $MAX_THREADS"
        $Global:RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, $MAX_THREADS)
        $Global:RunspacePool.ApartmentState = "MTA"
        [void]$Global:RunspacePool.Open()

        #region enumerate files
        $DriveLetters = Get-WmiObject Win32_Logicaldisk | Where-Object { $_.DriveType -in @(2,3,5,6) } | ForEach-Object { "$($_.DeviceId)\" }

        ForEach ( $DriveLetter in $DriveLetters ) {
            [array]$BaseDirectories  = Get-ChildItem $DriveLetter -Force -ErrorAction SilentlyContinue -Directory | Select-Object -ExpandProperty FullName #  | Where-Object { $_.PSIsContainer }
            Write-verbose "New-Runspace $DriveLetter"
            New-RunSpace -BaseDir $DriveLetter
            # For each parent directory on each drive, including recycle bin - spawn a thread to enumerate files
            ForEach ($BaseDir in $BaseDirectories) {
                if ( $null -eq $BaseDir ) { continue }  # PSv2 always enters into the loop even if the loop item is null, so it will process 1 null entry.
                Write-verbose "New-Runspace $BaseDir"
                New-RunSpace -BaseDir $BaseDir
                
                [array]$SubDirectories  = Get-ChildItem $BaseDir  -Force -ErrorAction SilentlyContinue -Directory |  Select-Object -ExpandProperty FullName #  | Where-Object { $_.PSIsContainer }
                ForEach ( $SubDir in $SubDirectories ) {
                    if ( $null -eq $SubDir ) { continue }  # PSv2 always enters into the loop even if the loop item is null, so it will process 1 null entry.
                    Write-verbose "New-Runspace $SubDir -Recurse"
                    New-RunSpace -BaseDir $SubDir -Recurse
                }
            } # ForEach ($BaseDir in $BaseDirectories)
        } # ForEach ( $DriveLetter in $DriveLetters )

        Write-Verbose "$($Global:JobThreads.count) jobs initiated."
        # Wait for each thread to complete
        ForEach ( $job in $Global:JobThreads ) {
            $currentBaseDir = $job.BaseDir
            Write-Verbose "Waiting for $currentBaseDir"

            [void]$job.AsyncResult.AsyncWaitHandle.WaitOne()
            $Data = $job.PowerShell.EndInvoke($job.AsyncResult)
            [void]$AllFiles.AddRange($Data[0..$Data.count])
            $job.PowerShell.Dispose()
        }
        if ( $AllFiles.Count -gt 0 ) {
            $AllFiles
        }
        #endregion enumerate files

        $RunspacePool.Dispose()
    } # ScriptBlock
}
PROCESS {
    $Jobs = New-Object -TypeName "System.Collections.ArrayList"
    $WorkingDir = (Get-Location).path
    $OutputFile = Join-Path $WorkingDir $("Log4Shell-{0}.csv" -f [datetime]::now.ToString("yyMMdd-HHmm"))
    $JobCount = 0
    if ( $PSBoundParameters.ContainsKey("Computername") -and $PSBoundParameters.ContainsKey("Credential") ) {
        ForEach ($Computer in $Computername) {
            $RunningJobs = $Jobs.Where({$_.State -eq "Running"}).Count
            if ( $RunningJobs -ge $MAXJOBS ) {

                do {
                    Write-Host "$RunningJobs Jobs running, $JobCount started out of $($Computername.count).   Sleeping."
                    ForEach ( $job in $Jobs.Where({$_.State -eq "Completed"}) ) {
                        Write-Host "Pulling results for $($Job.name)"
                        $result = $Job | Receive-Job                        
                        $result | Export-Csv -NoTypeInformation $OutputFile -Append
                        [void]$jobs.Remove($job)
                    }
                    Start-Sleep -Seconds 30
                    $RunningJobs = $Jobs.Where({$_.State -eq "Running"}).Count
                } while ($RunningJobs -ge $MAXJOBS)
            }

            Write-Verbose $Computer
            $IVParams = @{
                ComputerName = $Computer
                Credential = $Credential
                ScriptBlock = $ScriptBlock
                AsJob = $True
                JobName = $Computer
            }
            
            $Job = Invoke-Command @IVParams
            $Jobs.Add($Job) | Out-Null
            $JobCount++
        }

        if ( $Jobs.count -gt 0 ) {
            [int]$timeout = $TimeoutMinutes * 60
            Write-Host "Waiting up to $timeout seconds for $($Jobs.count) jobs to finish"
            $Jobs | Wait-Job -Timeout $timeout | Out-Null
            
            # for each job that did not return results back, log those items
            #ForEach ($item in $Computername.Where({$Jobs.Name -notcontains $_})) {
            #    Write-Host "Did not retrieve results for $item" -ForegroundColor Red
            #}
        
            # receive the results from the remaining, successful jobs
            ForEach ( $job in $Jobs.Where({$_.State -eq "Completed"}) ) {
                Write-Host "Pulling results for $($Job.name)"
                $result = $Job | Receive-Job
                $result | Export-Csv -NoTypeInformation $OutputFile -Append
            }

            # Any jobs still running or in a failed status - log the computer and state
            ForEach ($item in $Jobs.Where({$_.State -ne "Completed"})) {
                Write-Host "Job state for  $($item.Name) is $($item.State)" -Foreground Red
                #$Jobs.Remove($item) | Out-Null
                #$item | Remove-Job -Force | Out-Null
            }
            $Jobs | Remove-Job -Force
        }
    }
    else {
        $IvParams = @{
            ScriptBlock = $ScriptBlock
        }
        if ( $PSBoundParameters.ContainsKey("Credential") ) {
            $IvParams.Add("Credential", $Credential)
            $IvParams.Add("Computername", $Computername)
        }
        Invoke-Command @IvParams| Export-Csv -NoTypeInformation $OutputFile -Append
    }
}
END {
    Write-Information $OutputFile
}
