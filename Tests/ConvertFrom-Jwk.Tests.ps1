Get-Module Posh-ACME | Remove-Module -Force
Import-Module Posh-ACME -Force

Describe "ConvertFrom-Jwk" {

    InModuleScope Posh-ACME {

        Context "Key type agnostic Tests" {
            It "throws on bad JSON" {
                { 'asdf' | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'kty' #1" {
                { 1 | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'kty' #2" {
                { '{}' | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'kty' #3" {
                { '{"key1":"asdf"}' | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on empty 'kty'" {
                { '{"kty":""}' | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'kty'" {
                { '{"kty":"asdf"}' | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'kty'" {
                { '{"kty":"   "}' | ConvertFrom-Jwk } | Should -Throw
            }
        }

        # build some known good sample JWKs
        $rsa2048json = '{"kty":"RSA",' +
        '"n":"ttZMfCjzUB9sbN_L49FvbXOfSHdjj0i5hiDZSfvAPD7Jqheao5WoZP2akdz2j8uEOK4aYKXf6kYf6s1Ff7g6LSGO1f9LCupIJ8E6OLfinFP8UMYEesfibPGyS5bLMZNwVD7leJMeyEKChSBHHP6fqxC0Wh3L99qp2BJUufNyL4Tq-yhtSy9c9IBouh16Ci5vVsoogrglWuF1ocJYVPab3pausyQtdONrn6tJjpg9BXXu1EzWRDEmSs4pevTJoyixJiTlfc7AEwHGjunxeHW3bC7nvf3BIj9X105X8DFZMcA-gNxpKpbGr7IQV31tzVbPfRBPLdu2_ZfrfALCHCTomQ",' +
        '"e":"AQAB",' +
        '"d":"W93HJmdpAawYTYgRKRHVW_hJYx7hvl-7IAKnSv4cc-jUaQtdHq6Wos-t93Y_yLZoZBZOmJsfq9W6Ob8UGX1WddCztSCF8yEOSjNTbqYuTYABehBUteBzC2xRups0018ShLHpmLDLObH5ZKx4LsBdN5W4GMN59bo_tppXSethRzA1-p8TRgeunpzoW9DZZXnOqET0bZmFmaeOeXYeW-wUj6CyYJojP08EJXGmkWZsPf7n--4h8oLfAlLS33IWQe_a1sAhXfnMSwHv1NPs1F4kgPoTfLiJyiTnu5ZZ-_VKikFdkkI2Z12afufOYovzIol0vnqFR4SXIVuh74p9yyaipQ",' +
        '"p":"wFdY9JHH-nMmVR1dSzwVgp_eyUwLWiT8GuSt3CjeJZNs-Qrt4ijyxBGFJ2JVcVXs5OkjMYrsqRdIzytDBARHp00jL8gzS_LN_lhCB4nuGi3HwQBgxP-iAzDsad155Pn0J7UPIoWA4qVA8kV-UEdKYhHZFfuNhGcO8YN3U8vk9Is",' +
        '"q":"81mwl8YjdKXw_9YtiNY0Uf1hhTXGBxI_4J6llAgA-tz_wmmSDi3r4qTn6mhNSzJQP2Q7IPmx0KYrevYWj3D6jDXTBjIodjny8Bj1wLXLCLMBU-M7nZYslrRQPS6X1vx45cg0O9GL89GUCZEUmSOXFnK9Ox_NuuE1hlmgdy_N5-s",' +
        '"dp":"h_u5On_uwJS0nyx5jv1Vv9pDalHHHN5VFrZibOq_1BUc0B33_RMyP4ibeTK-cbhsGZLyfM5Zb1q08TMG2EomVpPksp16FtH87Tt8w1Oy8PM47KzVvbF124e1PUuGKGrHQWNy5dc5PgPTnPWgziT448j2j-IfNWKfYASwUqAuqO0",' +
        '"dq":"AUYL5Y906gxgSYZ-cIPmfDNeSkswwSK4UN2jsjWkg6uabxMMX6Sf4mzIhfKLzQPzZZGJua903cmw2pDlJ1UJCqjRdOvYSF4fRmBrENoiuOXu8Nh0nGuHyjYhYWCYDNj_bPxyQYnkOJ91LeOjfvWvub9Z_DA7bGn3VL-tVlJauoc",' +
        '"qi":"ghgWR7TIpdVYWTbuGaX4Ki3qY0v0a_bdG0YqKDABihVHaZvEBX6CzLDLZw8sjtL9F-UpKZN8VYIy5dabLqBY4FJqb2kvF9DT8qDG_8eamOVUwoM2OW4RanQ-Ti_yYClwP3D6Ljxqh2AX6636LDvPFrNRr2ZRapI_YuR3TmAmSNA"' +
        '}'
        $rsa2048 = $rsa2048json | ConvertFrom-Json
        $rsa3072json = '{"kty":"RSA",' +
        '"n":"yTjlmQ9AZeQp5Gnq-aYPbl5b4qvT_WzYD_-g7aHiJHYrDw07SVGf2w1Bpgi6GOE6XdhEJ1FB83lsdPCM4pz_J68Fihk9t6n09IR97iwymS4QGquoP0P0HytjqbY_UNs-H5HXOt_7gpz9BFoycsNXLxqvb-CqhPF_j0W0o5arfwQNA8pKnxBjt_8VdpJdNVBYiR6FMf17b0Q2rVJCVGem0CF6P3oKzyqFjA0KVvLzYOX66HYVNypCq0fdbPZxe3GjzFTzdI-_CLmfr0N5279bC0WhUSA39uXu4AV7-HvTUtBwkwuzl0BzW5eMmb68irbCD6yRZoSAjc7OlCWi2S7vZRiZkf9LsQ_RvZKyE9ESZFjLJ4USN_SJetx8YhfDIDJBmNDPRmeWg0Do17LeoUofwF5yits8RljM94mIZzzD9ddRClpECtg0p6ccAtIwYngv7ES6ryh8mj4vkcMdJ38lq9jkVMW2lP8kwiQEYXpPceibGz1NGGx-gkAvyDfaTw01",' +
        '"e":"AQAB",' +
        '"d":"UrpRqtvaXgmwL3hcYscjEP06SbbbMRXOvsUaJJipoNP0X_vQpBQq5KROmTR9Tj1LAcooOwHtW2xQasN7KK_jNy192YkHFruJOf4-x-zj4JZPiKeKRHhrpWTxVJTY8yUwJUqQcmQjw09HtsJee1BUR8lw105GzOF80CqYWalYWKARub0xcLQMS1lUOatzJrghrj4eBK9yUAx7bkajfpAexPL-j5pdV07kGPBDj_vSk8P5pBjoIAX_4uto3aN0hIvzUNZ1x3Y9ASt9qulAbIz1Xznnn8mGQNGkItqP_hjSWi9ZwxlCrvD53Lig2-17ivvOB8KGpvk2VytQwf-5DrHaYzcGc0uelH7IOI1IZ-6ID7CXjKOg8WEDntPlHzlpOhaKJ5nLcG7ZCxZTvuWPPi4f1oEEZKIm_jZRNRp7rxBg2WP-UKUIcy_LCxQ-EcJ2mSb0WMxkYwIbIqs7PYM21BwdnOpmX29zJkAHZqzPhRyq4vlCNZNmma_YY8i0xewi7icB",' +
        '"p":"1ZeQsP9id_WRGIq6XlvXXqVAnDBNIQfck6b9rAy_nWkCuAw4dPmweIxSyefFz2FSVj6U87tMmUlKAPgu1J5zJtSH_X3ahmFCf4kByHbPodI5bKIktI5GxzixiWU4GH79U1bBULqk4aTG2Rjnv1XBn3eugekOTWU-zpxAf2OliIyB_zjAaxI7v6VoXutgIPwkAyjDt4dM4K7a7djzDIiJ57BoETCwJBa3zaQs50xWsez0MlE3FWFP29zQEWHKvReL",' +
        '"q":"8SyZ0IX7Wt7SyNJ7yUVldXNQpxewXKIhAF859bMGdFLeem_rjM6VJqssPSg5FWlD6LPHJscZpvnjnMAL5lxolanUXtLBIKx2ZMAaM7lF0TB1LUAjbrTOj4o3NNW7L9Xi_zTbZGZRKCcW2PbdnKiuWb-X5U-2e2jEeWLIuiC4ezthsp_BavHFRL6598-gkEDvVVb5jqzB6_g-XMjUwMm_GdIbfIiv41kYEJU3r-Dl5yoe3SnXj0vFRCxp6ZoUywY_",' +
        '"dp":"hSrGD1RqdBgqqn5zy7i_AkdNjROgQuO_5l7K8aXRIbcC9vTHjkbOe5ohU7ipX65xw0upWnyAOWG0Pf5-VBml-aOwVZ9Ny1KAPzuQXQeWVHHZU52T_O5nunXiWqM84ijqkDcat9ZmTjiJsXkRo_03htD7gAtp218wVWid3c6mugfAVPtxHFB15_qco_FkMayCV2XnAFne2IasAHausjW-pTEa8PzGFPoFBrVBOcQimTP-3BA-o5nUTGPTZcLuwA4Z",' +
        '"dq":"oPgh2bnzYF1k1sEV-eqlo1TKOhxnjAxydmsYplNNNYqyD4pv71Va26pYJqGYKCBQQRrtC4bMKlSThOXxi1mWPH5Tzs5gNMynYOuPEYLRhKQRMZijjZqEW-3mlw8olu7tSWUgIczg0in05-8tTwiPBjwIx_cCVzBAIry6OPDp8OZbePuD_ztLbWzXdv1Pr7iHhbA9dOr9q9_Oz-MDjYGaWUORMPeSXe3zT-4ocu1qxXWpj_gDdhMeoTf7oP1Eb5XF",' +
        '"qi":"niXMKJ18-pSXXZOCP0MWgSOtYJr85-VIN5yWbaz07KLJiUKxnqJzUpGh001HYA7dvuhP2d3gbMiNYlgi6xwqXquCx5vAJ2GOHkgw2Pnv7cEfV0AvmfYC9YiTAFAmUwd4PzbJzrxeHPyMoeAA3iyd4oDsd10qwGeVL3DDlWoYz-3vC-uhbHAfhgHTDrbpWvWsigwW7GqPNGlfk_M1TRuLByMYrPPPQyf45GUBMaDP2rBK8SwW3XraaIdRhPe-XG4X"' +
        '}'
        $rsa3072 = $rsa3072json | ConvertFrom-Json
        $rsa4096json = '{"kty":"RSA",' +
        '"n":"wcK4LDqVwOP4eEAQze06WjWHY1s1xKZVEjCRyueQOk_8dD9zpHSzy9i3WAK8fcfd2OX_tqlQO_yfHUHbw1ju3Oo8XAMHgIT-ZPSJ14GPgAWVqG8MFQFndYVqzQeuCZKxXGhO8Fc7sJjobTGexCB3Xh8lXn9HJirA9dEx7rHl4yLLD7es_ZiHgg4ydx8j26lAANHI9d5hDaxwx6Y6bprgjvuPBRMku5Gmy5hPYZG-aZ2z1zyYU7bnCJoM5RZY8lueh9Yjy6iYHyHTa5ZoK-nqB-HTNOp0vShHFU_jJDLQMXskbUZjJa6VSSeEvJAENePdyKZQcfeyaMjEOP6hP02rh5Sw793rdUueQle8GpmpjV9KwfdzWa979R8MYAqPmGlSel_EVxmZGjFXGp6C5RP8aLzYya2vDDnJMNOo0iavOfACw-iPIn3QD0IQE0o_LBcRuQ26V3ZECd9uxHsK8LtGJVgLAmMTnV2cN6sW_wbSdQ5ZRNTbz3bd9Eu7SinUgrMkJWb3uWyFbY_mmX3KYl1TmyHZbbphWpeno2an0RdX-q_dSD2vO7HmcOeSUYo7Ssm7O4h5VO-0NpRDAqhxzKiFSJEx9IbeQ1HCtmaHV4o3_COMdLELGtJi4DqM3F1a6G9f2YkxgsEvZ7nQvJx_XiM5xmV6TZu_wQCmeI5sHDQudME",' +
        '"e":"AQAB",' +
        '"d":"ocGlb4cZLgcjj4Ashz3c0SKO_GtQ3_LcYmsZy4K17XiJEaNHL6wdzbgGl_rw0TDiDAk3CY8f5HRpgUtR5CuCffsumMIOqURd_HoJ-Ve4LPB8mDjcpUyeyoWvO6uFp4hHeRW7kPnCYxPENiSOnr1b6b-mutUW2M4oeQ9D2Dm76XtKerykNrH3rqObjcb5cJBDVmvMkTYtX_Tt0j772QqDHdr08w-gQta9oIpu-s1pYVK-qJl1sa2oAo5Y5YdaijnihxRGnecJ2DOtBMxz-vU044-reymge6n8bdZbkgS5uhVLu85fRz4QcxoCvkicu0CYDsKJthtLXh79cXdhti9pWjj8ntXXC1jCHF4ZMtzB0Z5IXiuLAjQyl78XtDXsnQQqWOL8TM2vbRmEfq_00YrdAkR_nuyOdotahv2F3uh9cOZRgwwX_UYWGuO0Y_FnBepCpzGHviafP3DdmmhUa3DVkGuQfBFf0FxiqxP5MGdCLDbinSgd0Rld6goO-OwCA4g6bLg7ZwcV-OXGxr_rkC_tc748nS1NmEeLU9UPj3iFT8t1kVAOHkOF48aOmR6Tk257N_ZnpcIUs7bSfgXT-Zt9WmFP9JJ_qNL0qckuNoLpnTKpksWB3cFyCEEZ_9FjFJVB1rylaNZMEbtu_HBDuLqsEIV63gyhe20k1uCJiboQeOE",' +
        '"p":"yP5GAkSnUtHLPITQLlTB7g83rgAdjeMuAfS8LvHbXQTheAjXRmsm-IFrmypZk0tNcR5EMapTcss0giCf8OBUM7YB1qBYfW1FjDlvqeSG9NJCR2oOOEGsOLV0yy7y1DAwmTFOWfFjPlQMAfRPesvfAbjy7CUB64Ckglg_dYTvcJmnSBgE_w8De7s8TJuV7k1qqUUGW6Hc69HcQTl9wy6ESuWSyk5yuTy6k1hhp40XmeKv20QLVoY5b4Kv1wRhRJBVznYGOmcJm37GEkT8ZcZxFmNmi9LGco0jiCVuica5ldzRU3G_1RkOwwhukbrHR-mduujVA22SvNzdeni2RV2Bxw",' +
        '"q":"9sm5AbFa3kVioTw6LuS60mXRY98zTQiIS1Lq4NC-updaVKx9a4JsAwlzn98lDUHVZwufEZKwMmFutio4W1UflqGvjV7a7hDOdKwK8zcpkEJNUUR_E99gKKDHGxvL3lJnSIW-gg89nwZBMM7RFZPgiOg-_i-0K0e8FCJ0_5LX5oEchaAJKa_CxqYCPNA-b7WBYe5zOinikJrX85e0WmQK7CXz77snl7sos5fIEhXXPk0UcmdaP2fB3yKsUT_nhMo14hds68ITG2HJolfX-Vu4Nld7wG4t9AfZ4SWBnMOoIQPbCUKP2NyNQmR5KuvtEiqi_PDoOH8P1rVWBwjfrvvVNw",' +
        '"dp":"T0wCUuLDIOmkRTwg5iaKXGGklgF1p4T5ocvscpj48rn6OmFCjYW42lI1IgKTVIlhBD_sp6uLQL7q-GvmriHTFpO4JfUc9F8oESqX429Fz1Ek1QgClC9UwwrUCVV8eDqK8eWCA_o4LV77XcoFkWzdjtBpBsGTAFbAkKxAXR0VWldEqCzRy88gkLBOGetIO7xPWHjjCUPS5TbmrtT_yQGRL_ti7m4E1RAgjAFShcgkh5Hnz5oI3xoVjukAdtRDi8lmEQ5_ZotAPxjFDHArI_wmoa6VxpRhts_4NL6P3cuJbJax_znhdTFtoYSyGsyV0slYcWVqpO-V9O0udCMrxjIeAQ",' +
        '"dq":"wFZFRyl3nYXMMcdjvUpsxC-werrpG5-LwdDU1_Q4wenV7-ojMZgLIG7MW4wpL2TgshffmG2PvyQqifTryVrVbKuEy5Ri4mnczheLzTRvw0u5QJ42wEE2i1OK-fi28gWdE2uRJ4JDT14rjqORVtTSiUEgXzDEpXqZ_cNBFjLW64IyvX4VxhSCpBmb4tOV5bA7Lx0NVwZv2q2joujYGh6gWJ3XuT5OxDWMqjOgLWAySg7-4Y7lSkdOVN6MGCLLCLYkOppxPGkcRRn4cPsvittN_aQ_AaGdVPSNfaiilI_0yA5eNqBWxfhWa6ksuiP3t1Hdh28mPWnh6T-Y1ZC37IO_Dw",' +
        '"qi":"IlO6vs-8_HiAY0keF5Q7Jb6Yp9C1WSo4Px2usVpjfADL_jKh8lLrJhpmqBnZTUVvGo9RrPoxkruw8kkW2QIFpPQq-CmN2szIH5QzE3-_4oiWalLX0qmg2CGHgUSEp3wu4BAAf30bxEL6l3bbo3oWYWAKymD5ZGdf3QccxIbpdtT8BdUeuEfZ-C2v8CeTq7aC2SsW9UkVvZPA9raHr1ojbhTT9VoQ0gdfSA6wdc3Yw8uRK4TZCpKWfukk0b_-KaFihZKXXBUgqzDfu6swfr_-Kbp7VwbjP73WRPCXG3zFPirh3AFC0ZjvE58G-GF-P_YhuHE5ca1syW7Wx4hcIsE9lQ"' +
        '}'
        $rsa4096 = $rsa4096json | ConvertFrom-Json

        Context "RSA Error Conditions" {

            # test public pieces
            It "throws on missing 'e'" {
                $missingE = $rsa2048 | Select kty,n
                { $missingE | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'e'" {
                $whitespaceE = $rsa2048 | Select kty,n,@{L='e';E={'   '}}
                { $whitespaceE | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'e'" {
                $invalidE = $rsa2048 | Select kty,n,@{L='e';E={'12345'}}
                { $invalidE | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'n'" {
                $missingN = $rsa2048 | Select kty,e
                { $missingN | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'n'" {
                $whitespaceN = $rsa2048 | Select kty,e,@{L='n';E={'   '}}
                { $whitespaceN | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'n'" {
                $invalidN = $rsa2048 | Select kty,e,@{L='n';E={'12345'}}
                { $invalidN | ConvertFrom-Jwk } | Should -Throw
            }

            # Test missing each one of these d,p,q,dp,dq,qi
            It "throws on incomplete priv key params #1" {
                $incompletePriv = $rsa2048 | Select kty,e,n,p,q,dp,dq,qi
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on incomplete priv key params #2" {
                $incompletePriv = $rsa2048 | Select kty,e,n,d,q,dp,dq,qi
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on incomplete priv key params #3" {
                $incompletePriv = $rsa2048 | Select kty,e,n,d,p,dp,dq,qi
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on incomplete priv key params #4" {
                $incompletePriv = $rsa2048 | Select kty,e,n,d,p,q,dq,qi
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on incomplete priv key params #5" {
                $incompletePriv = $rsa2048 | Select kty,e,n,d,p,q,dp,qi
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on incomplete priv key params #6" {
                $incompletePriv = $rsa2048 | Select kty,e,n,d,p,q,dp,dq
                { $incompletePriv | ConvertFrom-Jwk } | Should -Throw
            }

            # Test whitespace in each one of these d,p,q,dp,dq,qi
            It "throws on whitespace priv key params #1" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,p,q,dp,dq,qi,@{L='d';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace priv key params #2" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,d,q,dp,dq,qi,@{L='p';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace priv key params #3" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,d,p,dp,dq,qi,@{L='q';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace priv key params #4" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,d,p,q,dq,qi,@{L='dp';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace priv key params #5" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,d,p,q,dp,qi,@{L='dq';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace priv key params #6" {
                $whitespacePriv = $rsa2048 | Select kty,e,n,d,p,q,dp,dq,@{L='qi';E={'   '}}
                { $whitespacePriv | ConvertFrom-Jwk } | Should -Throw
            }

            # Test invalid in each one of these d,p,q,dp,dq,qi
            It "throws on invalid priv key params #1" {
                $invalidPriv = $rsa2048 | Select kty,e,n,p,q,dp,dq,qi,@{L='d';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid priv key params #2" {
                $invalidPriv = $rsa2048 | Select kty,e,n,d,q,dp,dq,qi,@{L='p';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid priv key params #3" {
                $invalidPriv = $rsa2048 | Select kty,e,n,d,p,dp,dq,qi,@{L='q';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid priv key params #4" {
                $invalidPriv = $rsa2048 | Select kty,e,n,d,p,q,dq,qi,@{L='dp';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid priv key params #5" {
                $invalidPriv = $rsa2048 | Select kty,e,n,d,p,q,dp,qi,@{L='dq';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid priv key params #6" {
                $invalidPriv = $rsa2048 | Select kty,e,n,d,p,q,dp,dq,@{L='qi';E={'12345'}}
                { $invalidPriv | ConvertFrom-Jwk } | Should -Throw
            }
            
        }

        Context "RSA 2048 Pub/Priv Test" {

            $rsa2048test = $rsa2048json | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa2048test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 2048 KeySize" {
                $rsa2048test.KeySize | Should -Be 2048
            }
            It "should not be PublicOnly" {
                $rsa2048test.PublicOnly | Should -Be $false
            }
            It "should not throw exporting params with private key" {
                { $rsa2048test.ExportParameters($true) } | Should -Not -Throw
            }
            $rsa2048Params = $rsa2048test.ExportParameters($true)
            It "should match 'n'" {
                $rsa2048Params.Modulus | Should -Be ($rsa2048.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa2048Params.Exponent | Should -Be ($rsa2048.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $rsa2048Params.D | Should -Be ($rsa2048.d | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'p'" {
                $rsa2048Params.P | Should -Be ($rsa2048.p | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'q'" {
                $rsa2048Params.Q | Should -Be ($rsa2048.q | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dp'" {
                $rsa2048Params.DP | Should -Be ($rsa2048.dp | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dq'" {
                $rsa2048Params.DQ | Should -Be ($rsa2048.dq | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'qi'" {
                $rsa2048Params.InverseQ | Should -Be ($rsa2048.qi | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "RSA 2048 Public Test" {

            $rsa2048test = $rsa2048 | Select kty,n,e | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa2048test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 2048 KeySize" {
                $rsa2048test.KeySize | Should -Be 2048
            }
            It "should be PublicOnly" {
                $rsa2048test.PublicOnly | Should -Be $true
            }
            It "should throw exporting params with private key" {
                { $rsa2048test.ExportParameters($true) } | Should -Throw
            }
            $rsa2048Params = $rsa2048test.ExportParameters($false)
            It "should match 'n'" {
                $rsa2048Params.Modulus | Should -Be ($rsa2048.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa2048Params.Exponent | Should -Be ($rsa2048.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should have null 'd'" {
                $rsa2048Params.D | Should -Be $null
            }

        }

        Context "RSA 3072 Pub/Priv Test" {

            $rsa3072test = $rsa3072json | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa3072test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 3072 KeySize" {
                $rsa3072test.KeySize | Should -Be 3072
            }
            It "should not be PublicOnly" {
                $rsa3072test.PublicOnly | Should -Be $false
            }
            It "should not throw exporting params with private key" {
                { $rsa3072test.ExportParameters($true) } | Should -Not -Throw
            }
            $rsa3072Params = $rsa3072test.ExportParameters($true)
            It "should match 'n'" {
                $rsa3072Params.Modulus | Should -Be ($rsa3072.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa3072Params.Exponent | Should -Be ($rsa3072.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $rsa3072Params.D | Should -Be ($rsa3072.d | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'p'" {
                $rsa3072Params.P | Should -Be ($rsa3072.p | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'q'" {
                $rsa3072Params.Q | Should -Be ($rsa3072.q | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dp'" {
                $rsa3072Params.DP | Should -Be ($rsa3072.dp | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dq'" {
                $rsa3072Params.DQ | Should -Be ($rsa3072.dq | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'qi'" {
                $rsa3072Params.InverseQ | Should -Be ($rsa3072.qi | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "RSA 3072 Public Test" {

            $rsa3072test = $rsa3072 | Select kty,n,e | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa3072test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 3072 KeySize" {
                $rsa3072test.KeySize | Should -Be 3072
            }
            It "should be PublicOnly" {
                $rsa3072test.PublicOnly | Should -Be $true
            }
            It "should throw exporting params with private key" {
                { $rsa3072test.ExportParameters($true) } | Should -Throw
            }
            $rsa3072Params = $rsa3072test.ExportParameters($false)
            It "should match 'n'" {
                $rsa3072Params.Modulus | Should -Be ($rsa3072.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa3072Params.Exponent | Should -Be ($rsa3072.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should have null 'd'" {
                $rsa3072Params.D | Should -Be $null
            }

        }

        Context "RSA 4096 Pub/Priv Test" {

            $rsa4096test = $rsa4096json | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa4096test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 4096 KeySize" {
                $rsa4096test.KeySize | Should -Be 4096
            }
            It "should not be PublicOnly" {
                $rsa4096test.PublicOnly | Should -Be $false
            }
            It "should not throw exporting params with private key" {
                { $rsa4096test.ExportParameters($true) } | Should -Not -Throw
            }
            $rsa4096Params = $rsa4096test.ExportParameters($true)
            It "should match 'n'" {
                $rsa4096Params.Modulus | Should -Be ($rsa4096.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa4096Params.Exponent | Should -Be ($rsa4096.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $rsa4096Params.D | Should -Be ($rsa4096.d | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'p'" {
                $rsa4096Params.P | Should -Be ($rsa4096.p | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'q'" {
                $rsa4096Params.Q | Should -Be ($rsa4096.q | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dp'" {
                $rsa4096Params.DP | Should -Be ($rsa4096.dp | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'dq'" {
                $rsa4096Params.DQ | Should -Be ($rsa4096.dq | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'qi'" {
                $rsa4096Params.InverseQ | Should -Be ($rsa4096.qi | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "RSA 4096 Public Test" {

            $rsa4096test = $rsa4096 | Select kty,n,e | ConvertFrom-Jwk

            It "is an RSA object" {
                $rsa4096test | Should -BeOfType [Security.Cryptography.RSA]
            }
            It "should have 4096 KeySize" {
                $rsa4096test.KeySize | Should -Be 4096
            }
            It "should be PublicOnly" {
                $rsa4096test.PublicOnly | Should -Be $true
            }
            It "should throw exporting params with private key" {
                { $rsa4096test.ExportParameters($true) } | Should -Throw
            }
            $rsa4096Params = $rsa4096test.ExportParameters($false)
            It "should match 'n'" {
                $rsa4096Params.Modulus | Should -Be ($rsa4096.n | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'e'" {
                $rsa4096Params.Exponent | Should -Be ($rsa4096.e | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should have null 'd'" {
                $rsa4096Params.D | Should -Be $null
            }

        }

        # build some known good sample JWKs
        $ec256json = '{"kty":"EC",' +
            '"crv":"P-256",' +
            '"x":"sK3uLNS2mZTTk1DIUqOfEQdLsthFFtDFB9DVWpo5WNk",' +
            '"y":"leltmmzdavAYd6OEm3zZPRRJehdKboo9l3ImNaUUNlg",' +
            '"d":"NjRylQeVhDqQ70ADD2cqWMI91g5griDRUukJS1sJftM"' +
            '}'
        $ec256 = $ec256json | ConvertFrom-Json
        $ec384json = '{"kty":"EC",' +
            '"crv":"P-384",' +
            '"x":"map4Lsdkx8TJABeGkewfLAFxpgDBqKOsUO9LX3vDfjNa1rXvhbxMdYF4qwfB6kv1",' +
            '"y":"VZx5-jpO_lpuPz-g_jHBPFuvX2VDRhSaUzhWJ3o0J1m9QnkfL5q0N-_AiN_2y0fC",' +
            '"d":"BEeJW0ltfMZxnMloDFC9zNlh1aZp7_-n6oOLyunwR6foD-pZNEra5D0GTfIdFjld"' +
            '}'
        $ec384 = $ec384json | ConvertFrom-Json
        $ec521json = '{"kty":"EC",' +
            '"crv":"P-521",' +
            '"x":"ATPrKkuPTDgihf3enWReEHxnpH4ReZ9pwdO6SDFm_JywrgjNmzzv0HBQFdyPgI84Ep7il8m8F7mWY4bSgRDTpqDV",' +
            '"y":"AVeFIlzLnc3VnrPhcApLQGT7J83iTv73LabwEhzMrEnA5_kL9_2k3TNVa7WCjl1w5Y0AmZ4va42iuvIwtdoG7TWf",' +
            '"d":"AFVFpOQqvRTQoA-ZXO_iP0-KhyHDcaQr9vSn9-JrdwxQ5tWxrhWzf3u32ziOtFCWo_AZ6xMgfqcWfQt34T5PHMCW"' +
            '}'
        $ec521 = $ec521json | ConvertFrom-Json

        Context "EC Error Conditions" {

            It "throws on missing 'crv'" {
                $missingCrv = $ec256 | Select kty,x,y
                { $missingCrv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'crv'" {
                $whitespaceCrv = $ec256 | Select kty,x,y,@{L='crv';E={'    '}}
                { $whitespaceCrv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'crv'" {
                $invalidCrv = $ec256 | Select kty,x,y,@{L='crv';E={'FAKE'}}
                { $invalidCrv | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'x'" {
                $missingX = $ec256 | Select kty,crv,y
                { $missingX | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'x'" {
                $whitespaceX = $ec256 | Select kty,crv,y,@{L='x';E={'    '}}
                { $whitespaceX | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'x'" {
                $invalidX = $ec256 | Select kty,crv,y,@{L='x';E={'FAKE'}}
                { $invalidX | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on missing 'y'" {
                $missingY = $ec256 | Select kty,crv,x
                { $missingY | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on whitespace 'y'" {
                $whitespaceY = $ec256 | Select kty,crv,x,@{L='y';E={'    '}}
                { $whitespaceY | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'y'" {
                $invalidY = $ec256 | Select kty,crv,x,@{L='y';E={'FAKE'}}
                { $invalidY | ConvertFrom-Jwk } | Should -Throw
            }
            It "throws on invalid 'd'" {
                $invalidD = $ec256 | Select kty,crv,x,y,@{L='d';E={'FAKE'}}
                { $invalidD | ConvertFrom-Jwk } | Should -Throw
            }

        }

        Context "EC P-256 Pub/Priv Test" {

            $ec256test = $ec256json | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec256test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 256 KeySize" {
                $ec256test.KeySize | Should -Be 256
            }
            It "should not throw exporting params with private key" {
                { $ec256test.ExportParameters($true) } | Should -Not -Throw
            }
            $ec256Params = $ec256test.ExportParameters($true)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P256'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP256'
                }
                $ec256Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec256Params.Q.X | Should -Be ($ec256.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec256Params.Q.Y | Should -Be ($ec256.y | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $ec256Params.D | Should -Be ($ec256.d | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "EC P-256 Public Test" {

            $ec256test = $ec256 | Select kty,crv,x,y | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec256test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 256 KeySize" {
                $ec256test.KeySize | Should -Be 256
            }
            It "should throw exporting params with private key" {
                { $ec256test.ExportParameters($true) } | Should -Throw
            }
            $ec256Params = $ec256test.ExportParameters($false)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P256'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP256'
                }
                $ec256Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec256Params.Q.X | Should -Be ($ec256.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec256Params.Q.Y | Should -Be ($ec256.y | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "EC P-384 Pub/Priv Test" {

            $ec384test = $ec384json | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec384test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 384 KeySize" {
                $ec384test.KeySize | Should -Be 384
            }
            It "should not throw exporting params with private key" {
                { $ec384test.ExportParameters($true) } | Should -Not -Throw
            }
            $ec384Params = $ec384test.ExportParameters($true)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P384'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP384'
                }
                $ec384Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec384Params.Q.X | Should -Be ($ec384.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec384Params.Q.Y | Should -Be ($ec384.y | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $ec384Params.D | Should -Be ($ec384.d | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "EC P-384 Public Test" {

            $ec384test = $ec384 | Select kty,crv,x,y | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec384test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 384 KeySize" {
                $ec384test.KeySize | Should -Be 384
            }
            It "should throw exporting params with private key" {
                { $ec384test.ExportParameters($true) } | Should -Throw
            }
            $ec384Params = $ec384test.ExportParameters($false)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P384'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP384'
                }
                $ec384Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec384Params.Q.X | Should -Be ($ec384.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec384Params.Q.Y | Should -Be ($ec384.y | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "EC P-521 Pub/Priv Test" {

            $ec521test = $ec521json | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec521test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 521 KeySize" {
                $ec521test.KeySize | Should -Be 521
            }
            It "should not throw exporting params with private key" {
                { $ec521test.ExportParameters($true) } | Should -Not -Throw
            }
            $ec521Params = $ec521test.ExportParameters($true)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P521'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP521'
                }
                $ec521Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec521Params.Q.X | Should -Be ($ec521.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec521Params.Q.Y | Should -Be ($ec521.y | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'd'" {
                $ec521Params.D | Should -Be ($ec521.d | ConvertFrom-Base64Url -AsByteArray)
            }

        }

        Context "EC P-521 Public Test" {

            $ec521test = $ec521 | Select kty,crv,x,y | ConvertFrom-Jwk

            It "is an ECDsa object" {
                $ec521test | Should -BeOfType [Security.Cryptography.ECDsa]
            }
            It "should have 521 KeySize" {
                $ec521test.KeySize | Should -Be 521
            }
            It "should throw exporting params with private key" {
                { $ec521test.ExportParameters($true) } | Should -Throw
            }
            $ec521Params = $ec521test.ExportParameters($false)
            It "should have correct curve name" {
                # curve names appear to be platform specific
                $curveName = 'ECDSA_P521'
                if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
                    $curveName = 'nistP521'
                }
                $ec521Params.Curve.Oid.FriendlyName | Should -BeExactly $curveName
            }
            It "should match 'x'" {
                $ec521Params.Q.X | Should -Be ($ec521.x | ConvertFrom-Base64Url -AsByteArray)
            }
            It "should match 'y'" {
                $ec521Params.Q.Y | Should -Be ($ec521.y | ConvertFrom-Base64Url -AsByteArray)
            }

        }

    }

}
