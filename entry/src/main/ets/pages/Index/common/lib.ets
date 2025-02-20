/**
 * https://github.com/iuroc/iuroc-ebook-scraper/blob/main/dist/lib.d.mts
 */

declare abstract class Category {
    id: number;
    chaoxingId: number;
    type: 'book' | 'magazine';
    name: string;
    /** 该分类下的书刊列表 */
    abstract items: ReadItem[];
}

declare abstract class ReadItem {
    id: number;
    name: string;
    surl: string;
    /** 内容介绍 */
    summary: string;
    /** 普通封面 */
    cover: string;
    chaoxingId: string;
    /** 该书刊所属的分类 */
    abstract category: Category;
}

declare abstract class Catalog {
    id: number;
    page: number;
    title: string;
    parentId: number;
    index: number;
    /** 该目录的子目录列表 */
    abstract childrens: Catalog[];
    /** 该目录的父目录 */
    abstract parent: Catalog;
}

declare abstract class Content {
    id: number;
    index: number;
    content: string;
}

declare class BookCategory extends Category {
    items: Book[];
}

declare class Book extends ReadItem {
    author: string;
    /** 出版社名称 */
    publish: string;
    /** 大尺寸封面 */
    bigCover: string;
    /** 图书专属，阅读器网页链接 */
    webReader: string;
    /** 图书专属，图书资源类型 */
    idType: 'HY' | 'GD';
    /** 图书专属 */
    isbn: string;
    category: BookCategory;
    catalogs: BookCatalog[];
    contents: BookContent[];
}

declare class BookCatalog extends Catalog {
    childrens: BookCatalog[];
    parent: BookCatalog;
    book: Book;
}

declare class BookContent extends Content {
    book: Book;
}

declare class MagazineCategory extends Category {
    items: Magazine[];
}

declare class Magazine extends ReadItem {
    /** 国内刊号 */
    cn: string;
    /** 国际刊号 */
    issn: string;
    category: MagazineCategory;
    issues: Issue[];
}

declare class MagazineCatalog extends Catalog {
    childrens: MagazineCatalog[];
    parent: MagazineCatalog;
    issue: Issue;
}

declare class Issue {
    id: number;
    issueId: string;
    name: string;
    cover: string;
    magazine: Magazine;
    surl: string;
    webReader: string;
    index: number;
    contents: MagazineContent[];
    catalogs: MagazineCatalog[];
}

declare class MagazineContent extends Content {
    issue: Issue;
}

export {
    Book,
    BookCatalog,
    BookCategory,
    BookContent,
    Catalog,
    Category,
    Content,
    Issue,
    Magazine,
    MagazineCatalog,
    MagazineCategory,
    MagazineContent,
    ReadItem,
};