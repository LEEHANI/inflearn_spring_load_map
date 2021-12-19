# 11. 파일 업로드 


# 파일 업로드 
## HTML 폼 전송 방식 
- `application/x-www-form-urlencoded`
- `multipart/form-data` 

## application/x-www-form-urlencoded
- HTML 폼 데이터를 서버로 전송하는 가장 기본적인 방법 
- ```
  <form action="/save" method="post">
    <input type="text" name="username" />
    <input type="text" name="age" />
    <button type="submit">전송</button>
  </form>
  ```
- ```
  POST /save HTTP/1.1
  HOST: localhost:8080 
  Content-Type: application/x-www-form-urlencoded 
  
  username=kim&age=20
  ```
- enctype 옵션이 없으면 헤더에 `Content-Type: application/x-www-form-urlencoded`를 추가한다. 
- 그리고 폼에 입력 내용은 `username=kim&age=20`처럼 `&`로 구분되어 전송된다. 

## multipart/form-data
- 파일을 업로드 하려면 `바이너리 데이터`를 전송해야 한다. 
- 또한 파일 뿐만 아니라 이름과 나이도 전송해야한다. 
- 즉, 문자와 바이너리를 동시에 전송해야 하는데, `multipart/form-data`가 이를 해결해준다.
- 이 방식을 사용하려면 form 태그에 별도의 `enctype="multipart/form-data"`를 지정해야 한다.
- ```
  <form action="/save" method="post" enctype="multipart/form-data">
    <input type="text" name="username" />
    <input type="text" name="age" />
    <input type="file" name="file1" />
    <button type="submit">전송</button>
  </form>
  ```
- ```
  POST /save HTTP/1.1 
  HOST: localhost:8080 
  Content-Type: multipart/form-data; boundary=------XXX
  Content-Length: 10457
  
  -----XXX
  Content-Disposition: form-data; name="username"
  
  lee
  -----XXX
  Content-Disposition: form-data; name="age"
  
  20
  -----XXX
  Content-Disposition: form-data; name="file1"; filename="intro.png"
  Content-Type: image/png
  
  12390812W@HJKQq2uoWkjaskldjqoi3591
  -----XXX--
  ```
- 생성된 HTTP 메시지를 보면 전송 항목이 `part`로 나뉘어져 있다. 
- `Content-Disposition`이라는 항목별 헤더가 추가되어 있고 여기에 부가 정보가 있다. 
- 위의 경우에는 username, age, file1로 각각 분리되어 있고, `파일의 경우 Content-Type: image/png이 추가되고 바이너리 데이터가 전송된다.`   

# 서블릿과 파일 업로드1 
- http://localhost:8080/servlet/v1/upload
- ```
  @PostMapping("/upload")
  public String saveFileV1(HttpServletRequest request) throws ServletException, IOException {
        log.info("request={}", request);

        String itemName = request.getParameter("itemName");
        log.info("itemName={}", itemName);

        Collection<Part> parts = request.getParts();
        log.info("parts={}", parts);

        return "upload-form";
  }  
  ```
- `request.getParts()`로 multipart/form-data 각각 나누어진 부분을 받아서 확인할 수 있다.
  + `parts=[org.apache.catalina.core.ApplicationPart@420aaeaa, org.apache.catalina.core.ApplicationPart@5c44b995]`
- logging.level.org.apache.coyote.http11=debug 옵션을 추가하면 `multipart/form-data` 방식으로 전송된 것을 확인할 수 있다. 
- 업로드 사이즈를 제한할 수 있다. 사이즐르 넘으면 예외(SizeLimitExceedeException)가 발생한다. 
- ```
  spring.servlet.multipart.max-file-size=1MB //파일 하나의 최대 사이즈 
  spring.servlet.multipart.max-request-size=10MB //전체 합 
  ```
## spring.servlet.multipart.enabled 
- spring.servlet.multipart.enabled=false 서블릿 컨테이너는 멀티파트와 관련된 처리를 하지 않는다. 
- ```
  request=org.apache.catalina.connector.RequestFacade@xxx 
  itemName=null
  parts=[]
  ```
- 옵션을 끄게되면 request.getParameter("itemName"), `request.getPart()`의 결과가 비어있게 된다.  
- `멀티파트는 일반적인 폼 요청인 application/x-www-form-urlencoded보다 훨씬 복잡하다.` 
- 옵션을 켜면 DispatcherServlet에서 `멀티파트 리졸버`를 실행하고, HttpServletRequest를 `MultipartHttpServletRequest`로 변환해서 반환한다. 
- `MultipartHttpServletRequest`는 HttpServletRequest의 자식 인터페이스이고, 멀티파트와 관련된 추가 기능을 제공한다.
- 멀티파트 리졸버는 MultipartHttpServletRequest 인터페이스를 구현한 `StandardMultipartHttpServletRequest` 를 반환한다.
- 컨트롤러에서 HttpServletRequest대신에 MultipartHttpServletRequest를 주입받을 수 있는데, MultipartFile이 더 사용하기 편리하므로 잘 쓰이진 않는다. 

# 서블릿과 파일 업로드2 
- 서블릿이 제공하는 `Part`에 대해 알아보고 실제 파일도 서버에 업로드 해보자. 
- 실제 파일 저장 경로. application.properties  
  + `file.dir=/Users/may/study/inflearn_spring_load_map/springmvc2/file/`
- http://localhost:8080/servlet/v2/upload
- ```
   @PostMapping("/upload")
    public String saveFileV2(HttpServletRequest request) throws ServletException, IOException {
        log.info("request={}", request);

        String itemName = request.getParameter("itemName");
        log.info("itemName={}", itemName);

        Collection<Part> parts = request.getParts();
        log.info("parts={}", parts);

        for (Part part : parts) {
            log.info("====== PART =====");
            log.info("name={}", part.getName());
            Collection<String> headerNames = part.getHeaderNames();
            for (String headerName : headerNames) {
                log.info("header {}: {}", headerName, part.getHeader(headerName));
            }
            //편의 메서드
            //content-disposition; filename
            log.info("submittedFilename={}", part.getSubmittedFileName());
            log.info("size={}", part.getSize());

            //데이터 읽기
            InputStream inputStream = part.getInputStream();
            String body = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
            log.info("body={}", body);

            //파일에 저장하기
            if(StringUtils.hasText(part.getSubmittedFileName())) {
                String fullPath = fileDir + part.getSubmittedFileName();
                log.info("파일 저장 fullPath={}", fullPath);
                part.write(fullPath);

            }
        }

        return "upload-form";
    }
  ```
- 멀티파트 형식은 데이터를 각각 부분(part)로 나누어 전송한다. request.getParts()에는 나뉘어진 데이터가 각각 담긴다.
- Part 주요 메서드 
  + part.getSubmittedFileName(): 클라이언트가 전달한 파일명 
  + part.getInputStream(): Part의 전송 데이터 
  + part.write(...): Part를 통해 전송된 데이터를 저장 
- ```
  ==== PART ====
  name=itemName
  header content-disposition: form-data; name="itemName" submittedFileName=null
  size=7
  body=상품A
  ==== PART ====
  name=file
  header content-disposition: form-data; name="file"; filename="스크린샷.png" header content-type: image/png
  submittedFileName=스크린샷.png
  size=112384
  body=qwlkjek2ljlese...
  파일 저장 fullPath=/Users/may/study/file/스크린샷.png
  ```
- `서블릿이 제공하는 Part는 편하긴 하지만, HttpServletRequest를 사용해야하고, 추가로 파일 부분만 구분하려면 여러가지 코드를 넣어야 한다.`

# 스프링과 파일 업로드 
- 스프링은 `MultipartFile` 이라는 인터페이스로 멀티파트 파일을 편리하게 지원한다. 
- ```
    @PostMapping("/upload")
    public String saveFile(@RequestParam String itemName,
                           @RequestParam MultipartFile file, 
                           HttpServletRequest request) throws IOException {

        log.info("request={}", request);
        log.info("itemName={}", itemName);
        log.info("multipartFile={}", file);

        if (!file.isEmpty()) {
            String fullPath = fileDir + file.getOriginalFilename();
            log.info("파일 저장 fullPath={}", fullPath);
            file.transferTo(new File(fullPath));
        }

        return "upload-form";
    }
  ```
- 업로드하는 이름에 맞추어 `@RequestParam MultipartFile file`를 적용하면 된다. 
- `@ModelAttribute`에서도 MultipartFile를 동일하게 사용할 수 있다.
- MultipartFile 주요 메서드 
  + file.getOriginalFilename(): 업로드 파일 명 
  + file.transferTo(): 파일 저장
- ```
  request=org.springframework.web.multipart.support.StandardMultipartHttpServletR equest@5c022dc6
  itemName=상품A 
  multipartFile=org.springframework.web.multipart.support.StandardMultipartHttpSe rvletRequest$StandardMultipartFile@274ba730
  파일 저장 fullPath=/Users/may/study/file/스크린샷.png
  ```

# 예제로 구현하는 파일 업로드, 다운로드 
- 고객이 같은 파일 이름으로 업로드 할 수 있으므로, 서버 내부에 별도의 파일명으로 관리해야한다. 
- ```
    @ResponseBody
    @GetMapping("/images/{filename}")
    public Resource downloadImage(@PathVariable String filename) throws MalformedURLException {
        return new UrlResource("file:" + fileStore.getFullPath(filename));
    }
  ```
- `UrlResource`로 이미지 파일을 읽어서 `@ResponseBody`로 이미지 바이너리를 반환한다. 
- ```
    @GetMapping("/attach/{itemId}")
    public ResponseEntity<Resource> downloadAttach(@PathVariable Long itemId) throws MalformedURLException {
        Item item = itemRepository.findById(itemId);
        String storeFileName = item.getAttachFile().getStoreFileName();
        String uploadFileName = item.getAttachFile().getUploadFileName();

        UrlResource resource = new UrlResource("file:" + fileStore.getFullPath(storeFileName));

        log.info("uploadFileName={}", uploadFileName);

        String encodedUploadFilName = UriUtils.encode(uploadFileName, StandardCharsets.UTF_8);
        String contentDisposition = "attachment; filename=\"" + encodedUploadFilName + "\"";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, contentDisposition)
                .body(resource);
    }
  ```
- 파일을 다운로드 할 때는 `Content-Disposition` 헤더에 `attachment; filename="업로드 파일명"` 값을 주면 된다.






